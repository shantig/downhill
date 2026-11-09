#include "RotaryControl.h"

#include <Wire.h>

#include "BoardConfig.h"

namespace {
constexpr uint8_t kFirstButtonPin = BoardConfig::kAnoSelectPin;
constexpr uint8_t kLastButtonPin = BoardConfig::kAnoRightPin;
}

bool RotaryControl::CheckedSeesaw::readVersionChecked(uint32_t& version) {
  uint8_t data[4] = {};
  if (!read(SEESAW_STATUS_BASE, SEESAW_STATUS_VERSION, data, sizeof(data))) {
    return false;
  }
  version = (static_cast<uint32_t>(data[0]) << 24) |
            (static_cast<uint32_t>(data[1]) << 16) |
            (static_cast<uint32_t>(data[2]) << 8) | data[3];
  return true;
}

bool RotaryControl::CheckedSeesaw::readEncoderChecked(int32_t& position) {
  uint8_t data[4] = {};
  if (!read(SEESAW_ENCODER_BASE, SEESAW_ENCODER_POSITION, data,
            sizeof(data))) {
    return false;
  }
  const uint32_t raw = (static_cast<uint32_t>(data[0]) << 24) |
                       (static_cast<uint32_t>(data[1]) << 16) |
                       (static_cast<uint32_t>(data[2]) << 8) | data[3];
  position = static_cast<int32_t>(raw);
  return true;
}

bool RotaryControl::CheckedSeesaw::readButtonsChecked(uint32_t& states) {
  uint8_t data[4] = {};
  if (!read(SEESAW_GPIO_BASE, SEESAW_GPIO_BULK, data, sizeof(data))) {
    return false;
  }
  states = (static_cast<uint32_t>(data[0]) << 24) |
           (static_cast<uint32_t>(data[1]) << 16) |
           (static_cast<uint32_t>(data[2]) << 8) | data[3];
  return true;
}

void RotaryControl::begin() {
  Wire.begin(BoardConfig::kI2cSda, BoardConfig::kI2cScl);
  Wire.setClock(BoardConfig::kI2cFrequencyHz);
  Wire.setTimeOut(BoardConfig::kI2cTimeoutMs);
  Serial.printf("ANO I2C: probing 0x%02X on SDA=GPIO%d SCL=GPIO%d\n",
                BoardConfig::kAnoAddress, BoardConfig::kI2cSda,
                BoardConfig::kI2cScl);
  connect(millis());
}

bool RotaryControl::probe() const {
  Wire.beginTransmission(BoardConfig::kAnoAddress);
  return Wire.endTransmission() == 0;
}

bool RotaryControl::connect(uint32_t now) {
  lastReconnectAttemptMs_ = now;
  if (!probe() || !seesaw_.begin(BoardConfig::kAnoAddress, -1, false)) {
    if (lastErrorLogMs_ == 0 ||
        now - lastErrorLogMs_ >= BoardConfig::kAnoErrorLogPeriodMs) {
      Serial.printf("ANO I2C: no response at 0x%02X\n",
                    BoardConfig::kAnoAddress);
      lastErrorLogMs_ = now == 0 ? 1 : now;
    }
    return false;
  }

  uint32_t version = 0;
  const uint16_t productId =
      seesaw_.readVersionChecked(version) ? version >> 16 : 0;
  if (productId != BoardConfig::kAnoProductId) {
    if (lastErrorLogMs_ == 0 ||
        now - lastErrorLogMs_ >= BoardConfig::kAnoErrorLogPeriodMs) {
      Serial.printf("ANO I2C: expected product %u, got %u\n",
                    BoardConfig::kAnoProductId, productId);
      lastErrorLogMs_ = now == 0 ? 1 : now;
    }
    return false;
  }

  for (uint8_t pin = kFirstButtonPin; pin <= kLastButtonPin; ++pin) {
    seesaw_.pinMode(pin, INPUT_PULLUP);
  }

  uint32_t buttonStates = 0;
  if (!seesaw_.readEncoderChecked(encoderPosition_) ||
      !seesaw_.readButtonsChecked(buttonStates)) {
    Serial.println(F("ANO I2C: initialization read failed"));
    lastErrorLogMs_ = now == 0 ? 1 : now;
    return false;
  }

  for (uint8_t pin = kFirstButtonPin; pin <= kLastButtonPin; ++pin) {
    const bool pressed = (buttonStates & (1UL << pin)) == 0;
    rawPressed_[pin] = stablePressed_[pin] = pressed;
    rawChangedMs_[pin] = now;
  }
  // SELECT held at boot/reconnect must be released before creating an event.
  buttonArmed_ = !stablePressed_[BoardConfig::kAnoSelectPin];
  longPressHandled_ = false;
  runningWhenPressed_ = false;
  connected_ = true;
  lastErrorLogMs_ = 0;
  lastPollMs_ = now;
  Serial.printf("ANO I2C: connected, product=%u, position=%ld%s\n",
                productId, static_cast<long>(encoderPosition_),
                buttonArmed_ ? "" : ", SELECT held; waiting for release");
  return true;
}

void RotaryControl::disconnect(const __FlashStringHelper* reason,
                               uint32_t now) {
  if (connected_) {
    Serial.print(F("ANO I2C: disconnected: "));
    Serial.println(reason);
  }
  connected_ = false;
  buttonArmed_ = false;
  longPressHandled_ = false;
  if (control_.source() == ControlCoordinator::Source::Physical &&
      motor_.isRunning()) {
    control_.guardPhysicalStop(true);
    control_.stop(ControlCoordinator::Source::Physical,
                  F("ANO I2C communication failure"));
  }
  lastReconnectAttemptMs_ = now;
  lastErrorLogMs_ = now == 0 ? 1 : now;
}

void RotaryControl::update() {
  const uint32_t now = millis();
  if (!connected_) {
    if (now - lastReconnectAttemptMs_ >= BoardConfig::kAnoReconnectPeriodMs) {
      connect(now);
    }
    return;
  }
  if (now - lastPollMs_ < BoardConfig::kAnoPollPeriodMs) return;
  lastPollMs_ = now;
  poll(now);
}

void RotaryControl::poll(uint32_t now) {
  int32_t position = 0;
  uint32_t buttonStates = 0;
  if (!probe() || !seesaw_.readEncoderChecked(position) ||
      !seesaw_.readButtonsChecked(buttonStates)) {
    disconnect(F("read/probe failed"), now);
    return;
  }

  // Unsigned subtraction gives defined wraparound at the int32 counter edge.
  const int32_t rawDelta = static_cast<int32_t>(
      static_cast<uint32_t>(position) -
      static_cast<uint32_t>(encoderPosition_));
  if (rawDelta != 0) {
    encoderPosition_ = position;
    applySteps(position, rawDelta);
  }
  for (uint8_t pin = kFirstButtonPin; pin <= kLastButtonPin; ++pin) {
    updateButton(pin, (buttonStates & (1UL << pin)) == 0, now);
  }
  updateSelectHold(now);
}

void RotaryControl::applySteps(int32_t position, int32_t rawDelta) {
  const int64_t clockwiseSteps =
      static_cast<int64_t>(rawDelta) * BoardConfig::kAnoClockwisePositionSign;
  const int64_t requested = static_cast<int64_t>(motor_.speedPercent()) +
                            clockwiseSteps *
                                BoardConfig::kRotarySpeedStepPercent;
  const uint8_t next = static_cast<uint8_t>(
      requested < 0 ? 0 : requested > 100 ? 100 : requested);
  control_.setSpeedPercent(ControlCoordinator::Source::Physical, next);
  Serial.printf("ANO ENCODER: position=%ld delta=%ld %s speed=%u%%\n",
                static_cast<long>(position), static_cast<long>(rawDelta),
                clockwiseSteps > 0 ? "CW" : "CCW", next);
}

void RotaryControl::updateButton(uint8_t pin, bool pressed, uint32_t now) {
  if (pressed != rawPressed_[pin]) {
    rawPressed_[pin] = pressed;
    rawChangedMs_[pin] = now;
  }
  if (pressed != stablePressed_[pin] &&
      now - rawChangedMs_[pin] >= BoardConfig::kButtonDebounceMs) {
    stablePressed_[pin] = pressed;
    handleButtonChange(pin, pressed, now);
  }
}

const char* RotaryControl::buttonName(uint8_t pin) const {
  switch (pin) {
    case BoardConfig::kAnoSelectPin: return "SELECT";
    case BoardConfig::kAnoUpPin: return "UP";
    case BoardConfig::kAnoLeftPin: return "LEFT";
    case BoardConfig::kAnoDownPin: return "DOWN";
    case BoardConfig::kAnoRightPin: return "RIGHT";
    default: return "UNKNOWN";
  }
}

void RotaryControl::handleButtonChange(uint8_t pin, bool pressed,
                                       uint32_t now) {
  Serial.printf("ANO BUTTON: %s %s\n", buttonName(pin),
                pressed ? "pressed" : "released");
  if (pin != BoardConfig::kAnoSelectPin) return;

  if (pressed) {
    if (!buttonArmed_) return;
    pressedSinceMs_ = now;
    longPressHandled_ = false;
    runningWhenPressed_ = motor_.isRunning();
    return;
  }

  if (!buttonArmed_) {
    buttonArmed_ = true;
    Serial.println(F("ANO BUTTON: SELECT armed after release"));
    return;
  }
  if (longPressHandled_) return;

  if (runningWhenPressed_ || motor_.isRunning()) {
    control_.guardPhysicalStop(false);
    control_.stop(ControlCoordinator::Source::Physical,
                  F("ANO SELECT short press"));
  } else if (control_.start(ControlCoordinator::Source::Physical)) {
    Serial.println(F("ANO BUTTON: SELECT short press START"));
  } else {
    Serial.println(F("ANO BUTTON: SELECT START rejected"));
  }
}

void RotaryControl::updateSelectHold(uint32_t now) {
  if (!stablePressed_[BoardConfig::kAnoSelectPin] || !buttonArmed_) return;
  control_.guardPhysicalStop(true);
  if (longPressHandled_ ||
      now - pressedSinceMs_ < BoardConfig::kButtonLongPressMs) return;

  longPressHandled_ = true;
  control_.stop(ControlCoordinator::Source::Physical,
                F("ANO SELECT long press"));
  control_.setSpeedPercent(ControlCoordinator::Source::Physical,
                           BoardConfig::kDefaultSpeedPercent);
  Serial.printf("ANO BUTTON: SELECT long press STOP, preset=%u%%\n",
                BoardConfig::kDefaultSpeedPercent);
}
