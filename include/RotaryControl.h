#pragma once

#include <Arduino.h>

#include "ControlCoordinator.h"
#include "MotorController.h"

class RotaryControl {
 public:
  RotaryControl(ControlCoordinator& control, MotorController& motor)
      : control_(control), motor_(motor) {}

  void begin();
  void update();

 private:
  void updateRotation(uint32_t now);
  void updateButton(uint32_t now);
  void applyStep(int8_t direction);

  ControlCoordinator& control_;
  MotorController& motor_;
  uint8_t rotaryState_ = 0;
  uint8_t candidateState_ = 0;
  int8_t quarterSteps_ = 0;
  uint32_t candidateSinceMs_ = 0;
  bool rawPressed_ = false;
  bool pressed_ = false;
  bool buttonArmed_ = false;
  bool longPressHandled_ = false;
  bool runningWhenPressed_ = false;
  uint32_t rawChangedMs_ = 0;
  uint32_t pressedSinceMs_ = 0;
};
