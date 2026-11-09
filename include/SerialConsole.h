#pragma once

#include <Arduino.h>

#include "Encoder.h"
#include "ControlCoordinator.h"
#include "MotorController.h"

class SerialConsole {
 public:
  SerialConsole(MotorController& motor, Encoder& encoder,
                ControlCoordinator& control)
      : motor_(motor), encoder_(encoder), control_(control) {}

  void begin();
  void update();

 private:
  void execute(String command);
  void printHelp() const;
  void printStatus() const;
  void acknowledge();

  MotorController& motor_;
  Encoder& encoder_;
  ControlCoordinator& control_;
  String input_;
};
