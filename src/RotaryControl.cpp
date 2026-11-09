#include "RotaryControl.h"

#include "BoardConfig.h"

namespace {
// Valid Gray-code transitions. Bounce/reversals cancel rather than producing
// a complete detent, and an event is emitted only after four quarter-steps.
constexpr int8_t kTransition[16] = {
    0, -1, 1, 0, 1, 0, 0, -1, -1, 0, 0, 1, 0, 1, -1, 0};
}

void RotaryControl::begin() {
  pinMode(BoardConfig::kRotaryA, INPUT_PULLUP);
  pinMode(BoardConfig::kRotaryB, INPUT_PULLUP);
  pinMode(BoardConfig::kRotaryButton, INPUT_PULLUP);
  rotaryState_ = candidateState_ =
      (digitalRead(BoardConfig::kRotaryA) << 1) |
      digitalRead(BoardConfig::kRotaryB);
  rawPressed_ = pressed_ = digitalRead(BoardConfig::kRotaryButton) == LOW;
  // A button held during boot must be released before it can create an event.
  buttonArmed_ = !pressed_;
  candidateSinceMs_ = rawChangedMs_ = millis();
  Serial.println(F("Rotary control ready: A=GPIO26 B=GPIO27 SW=GPIO32"));
}

void RotaryControl::update() {
  const uint32_t now = millis();
  updateRotation(now);
  updateButton(now);
}

void RotaryControl::updateRotation(uint32_t now) {
  const uint8_t sample = (digitalRead(BoardConfig::kRotaryA) << 1) |
                         digitalRead(BoardConfig::kRotaryB);
  if (sample != candidateState_) {
    candidateState_ = sample;
    candidateSinceMs_ = now;
    return;
  }
  if (sample == rotaryState_ ||
      now - candidateSinceMs_ < BoardConfig::kRotaryDebounceMs) return;

  const int8_t delta = kTransition[(rotaryState_ << 2) | sample];
  rotaryState_ = sample;
  if (delta == 0) {
    quarterSteps_ = 0;
    return;
  }
  quarterSteps_ += delta;
  if (quarterSteps_ >= 4) {
    quarterSteps_ = 0;
    applyStep(1);
  } else if (quarterSteps_ <= -4) {
    quarterSteps_ = 0;
    applyStep(-1);
  }
}

void RotaryControl::applyStep(int8_t direction) {
  const int next = constrain(static_cast<int>(motor_.speedPercent()) +
                                 direction * BoardConfig::kRotarySpeedStepPercent,
                             0, 100);
  control_.setSpeedPercent(ControlCoordinator::Source::Physical,
                           static_cast<uint8_t>(next));
  Serial.printf("ROTARY: %s, speed=%d%%\n",
                direction > 0 ? "clockwise" : "counterclockwise", next);
}

void RotaryControl::updateButton(uint32_t now) {
  const bool sample = digitalRead(BoardConfig::kRotaryButton) == LOW;
  if (sample != rawPressed_) {
    rawPressed_ = sample;
    rawChangedMs_ = now;
  }
  if (sample != pressed_ &&
      now - rawChangedMs_ >= BoardConfig::kButtonDebounceMs) {
    pressed_ = sample;
    if (pressed_) {
      if (!buttonArmed_) return;
      pressedSinceMs_ = now;
      longPressHandled_ = false;
      runningWhenPressed_ = motor_.isRunning();
      Serial.println(F("ROTARY BUTTON: pressed"));
    } else {
      if (!buttonArmed_) {
        buttonArmed_ = true;
        return;
      }
      if (!longPressHandled_) {
        // Preserve the gesture's press-time intent. If a watchdog stops the
        // motor while this press is held, release must not become a START.
        if (runningWhenPressed_ || motor_.isRunning()) {
          control_.guardPhysicalStop(false);
          control_.stop(ControlCoordinator::Source::Physical,
                        F("short press"));
        } else if (control_.start(ControlCoordinator::Source::Physical)) {
          Serial.println(F("ROTARY BUTTON: short press START"));
        }
      }
    }
  }

  if (pressed_ && buttonArmed_) {
    control_.guardPhysicalStop(true);
    if (!longPressHandled_ &&
        now - pressedSinceMs_ >= BoardConfig::kButtonLongPressMs) {
      longPressHandled_ = true;
      control_.stop(ControlCoordinator::Source::Physical, F("long press"));
      control_.setSpeedPercent(ControlCoordinator::Source::Physical,
                               BoardConfig::kDefaultSpeedPercent);
      Serial.printf("ROTARY BUTTON: long press STOP, preset=%u%%\n",
                    BoardConfig::kDefaultSpeedPercent);
    }
  }
}
