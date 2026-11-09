#pragma once

#include <Arduino.h>

#include "MotorController.h"

class ControlCoordinator {
 public:
  enum class Source : uint8_t { None, Physical, Web, Serial };

  explicit ControlCoordinator(MotorController& motor) : motor_(motor) {}

  void begin();
  bool start(Source source);
  void stop(Source source, const __FlashStringHelper* reason);
  void setSpeedPercent(Source source, uint8_t percent);
  void setDirection(Source source, MotorController::Direction direction);
  void activity(Source source);
  void update();
  void guardPhysicalStop(bool buttonHeld);

  Source source() const { return source_; }
  const char* sourceName() const;
  bool canStart(Source source) const;
  uint32_t serialTimeoutMs() const { return serialTimeoutMs_; }
  bool setSerialTimeoutMs(uint32_t timeoutMs);

 private:
  void takeOwnership(Source source);

  MotorController& motor_;
  Source source_ = Source::None;
  uint32_t lastActivityMs_ = 0;
  uint32_t serialTimeoutMs_ = 0;
  uint32_t physicalStopGuardUntilMs_ = 0;
};
