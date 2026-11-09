#include "ControlCoordinator.h"

#include "BoardConfig.h"

void ControlCoordinator::begin() {
  motor_.stop();
  motor_.setSpeedPercent(BoardConfig::kDefaultSpeedPercent);
  source_ = Source::None;
  serialTimeoutMs_ = BoardConfig::kDefaultCommandTimeoutMs;
  lastActivityMs_ = millis();
}

const char* ControlCoordinator::sourceName() const {
  switch (source_) {
    case Source::Physical: return "PHYSICAL";
    case Source::Web: return "WEB";
    case Source::Serial: return "SERIAL";
    default: return "NONE";
  }
}

void ControlCoordinator::takeOwnership(Source source) {
  if (source_ == source) return;
  motor_.stop();
  Serial.printf("CONTROL: %s -> %s (safe stop)\n", sourceName(),
                source == Source::Physical ? "PHYSICAL" :
                source == Source::Web ? "WEB" : "SERIAL");
  source_ = source;
  lastActivityMs_ = millis();
}

bool ControlCoordinator::canStart(Source source) const {
  if (source == Source::Physical) return true;
  return static_cast<int32_t>(millis() - physicalStopGuardUntilMs_) >= 0;
}

bool ControlCoordinator::start(Source source) {
  if (!canStart(source) || motor_.speedPercent() == 0) return false;
  takeOwnership(source);
  lastActivityMs_ = millis();
  motor_.start();
  return motor_.isRunning();
}

void ControlCoordinator::stop(Source source,
                              const __FlashStringHelper* reason) {
  motor_.stop();
  if (source_ != source) takeOwnership(source);
  lastActivityMs_ = millis();
  Serial.printf("CONTROL: %s STOP: ", sourceName());
  Serial.println(reason);
}

void ControlCoordinator::setSpeedPercent(Source source, uint8_t percent) {
  takeOwnership(source);
  lastActivityMs_ = millis();
  motor_.setSpeedPercent(percent);
}

void ControlCoordinator::setDirection(
    Source source, MotorController::Direction direction) {
  takeOwnership(source);
  lastActivityMs_ = millis();
  motor_.setDirection(direction);
}

void ControlCoordinator::activity(Source source) {
  if (source_ == source) lastActivityMs_ = millis();
}

void ControlCoordinator::update() {
  if (source_ == Source::Serial && motor_.isRunning() &&
      millis() - lastActivityMs_ >= serialTimeoutMs_) {
    motor_.stop();
    Serial.println(F("TIMEOUT: serial motor stopped; issue START to resume."));
  }
}

void ControlCoordinator::guardPhysicalStop(bool buttonHeld) {
  (void)buttonHeld;
  physicalStopGuardUntilMs_ = millis() + BoardConfig::kPhysicalStopGuardMs;
}

bool ControlCoordinator::setSerialTimeoutMs(uint32_t timeoutMs) {
  if (timeoutMs < 500 || timeoutMs > 30000) return false;
  serialTimeoutMs_ = timeoutMs;
  lastActivityMs_ = millis();
  return true;
}
