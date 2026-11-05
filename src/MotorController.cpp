#include "MotorController.h"

#include "BoardConfig.h"

void MotorController::begin() {
  // Establish a disabled bridge state before attaching PWM.
  pinMode(BoardConfig::kMotorIn1, OUTPUT);
  pinMode(BoardConfig::kMotorIn2, OUTPUT);
  digitalWrite(BoardConfig::kMotorIn1, LOW);
  digitalWrite(BoardConfig::kMotorIn2, LOW);

  ledcSetup(BoardConfig::kPwmChannel, BoardConfig::kPwmFrequencyHz,
            BoardConfig::kPwmResolutionBits);
  ledcAttachPin(BoardConfig::kMotorPwm, BoardConfig::kPwmChannel);
  ledcWrite(BoardConfig::kPwmChannel, 0);
}

void MotorController::start() {
  if (speedPercent_ == 0) {
    return;
  }
  running_ = true;
  applyOutput();
}

void MotorController::stop() {
  running_ = false;
  ledcWrite(BoardConfig::kPwmChannel, 0);
  // TB6612FNG short-brake is IN1=IN2=HIGH. LOW/LOW is standby/coast and is
  // the less surprising safe state for initial mechanical testing.
  digitalWrite(BoardConfig::kMotorIn1, LOW);
  digitalWrite(BoardConfig::kMotorIn2, LOW);
}

void MotorController::setDirection(Direction direction) {
  // Never reverse an energized bridge. Direction changes intentionally leave
  // the motor stopped; even re-selecting the current direction is a stop action
  // and a separate START command is required.
  stop();
  if (direction != direction_) {
    delay(BoardConfig::kDirectionDeadTimeMs);
  }
  direction_ = direction;
}

void MotorController::setSpeedPercent(uint8_t percent) {
  speedPercent_ = constrain(percent, 0, 100);
  if (speedPercent_ == 0) {
    stop();
  } else if (running_) {
    applyOutput();
  }
}

void MotorController::applyOutput() {
  if (!running_ || speedPercent_ == 0) {
    stop();
    return;
  }

  // This polarity matches Waveshare's switchPortCtrlA(): positive/forward is
  // AIN1 LOW and AIN2 HIGH. Mechanical forward still depends on installation.
  const bool forward = direction_ == Direction::Forward;
  digitalWrite(BoardConfig::kMotorIn1, forward ? LOW : HIGH);
  digitalWrite(BoardConfig::kMotorIn2, forward ? HIGH : LOW);
  const uint8_t duty = static_cast<uint8_t>(
      (static_cast<uint16_t>(speedPercent_) * BoardConfig::kPwmMaximum) / 100U);
  ledcWrite(BoardConfig::kPwmChannel, duty);
}
