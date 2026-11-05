#include "Encoder.h"

#include "BoardConfig.h"

volatile int32_t Encoder::pulseCount_ = 0;
portMUX_TYPE Encoder::mux_ = portMUX_INITIALIZER_UNLOCKED;

void Encoder::begin() {
  // GPIO 34/35 have no ESP32 internal pull-ups. Waveshare specifies that the
  // motor encoder includes pull-ups; power it through the keyed board port.
  pinMode(BoardConfig::kEncoderA, INPUT);
  pinMode(BoardConfig::kEncoderB, INPUT);
  attachInterrupt(digitalPinToInterrupt(BoardConfig::kEncoderA), onPhaseARise,
                  RISING);
  lastSampleMs_ = millis();
}

void IRAM_ATTR Encoder::onPhaseARise() {
  const int direction = digitalRead(BoardConfig::kEncoderB) ? -1 : 1;
  portENTER_CRITICAL_ISR(&mux_);
  pulseCount_ += direction;
  portEXIT_CRITICAL_ISR(&mux_);
}

int32_t Encoder::count() const {
  portENTER_CRITICAL(&mux_);
  const int32_t value = pulseCount_;
  portEXIT_CRITICAL(&mux_);
  return value;
}

void Encoder::update() {
  const uint32_t now = millis();
  const uint32_t elapsed = now - lastSampleMs_;
  if (elapsed < BoardConfig::kRpmSamplePeriodMs) {
    return;
  }

  const int32_t current = count();
  const int32_t delta = current - lastCount_;
  rpm_ = (static_cast<float>(delta) * 60000.0F) /
         (BoardConfig::kEncoderPulsesPerOutputRevolution * elapsed);
  lastCount_ = current;
  lastSampleMs_ = now;
}
