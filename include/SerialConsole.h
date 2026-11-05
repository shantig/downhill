#pragma once

#include <Arduino.h>

#include "Encoder.h"
#include "MotorController.h"

class SerialConsole {
 public:
  SerialConsole(MotorController& motor, Encoder& encoder)
      : motor_(motor), encoder_(encoder) {}

  void begin();
  void update();
  void checkTimeout();
  void suspendWatchdog();
  void resumeWatchdog();

 private:
  void execute(String command);
  void printHelp() const;
  void printStatus() const;
  void acknowledge();

  MotorController& motor_;
  Encoder& encoder_;
  String input_;
  uint32_t lastValidCommandMs_ = 0;
  uint32_t timeoutMs_ = 0;
  bool watchdogSuspended_ = false;
};
