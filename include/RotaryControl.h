#pragma once

#include <Arduino.h>
#include <Adafruit_seesaw.h>

#include "ControlCoordinator.h"
#include "MotorController.h"

class RotaryControl {
 public:
  RotaryControl(ControlCoordinator& control, MotorController& motor)
      : control_(control), motor_(motor) {}

  void begin();
  void update();
  bool connected() const { return connected_; }

 private:
  class CheckedSeesaw : public Adafruit_seesaw {
   public:
    explicit CheckedSeesaw(TwoWire* wire) : Adafruit_seesaw(wire) {}
    bool readVersionChecked(uint32_t& version);
    bool readEncoderChecked(int32_t& position);
    bool readButtonsChecked(uint32_t& states);
  };

  bool probe() const;
  bool connect(uint32_t now);
  void disconnect(const __FlashStringHelper* reason, uint32_t now);
  void poll(uint32_t now);
  void updateButton(uint8_t pin, bool pressed, uint32_t now);
  void handleButtonChange(uint8_t pin, bool pressed, uint32_t now);
  void updateSelectHold(uint32_t now);
  void applySteps(int32_t position, int32_t rawDelta);
  const char* buttonName(uint8_t pin) const;

  ControlCoordinator& control_;
  MotorController& motor_;
  CheckedSeesaw seesaw_{&Wire};
  bool connected_ = false;
  bool rawPressed_[6] = {};
  bool stablePressed_[6] = {};
  uint32_t rawChangedMs_[6] = {};
  bool buttonArmed_ = false;
  bool longPressHandled_ = false;
  bool runningWhenPressed_ = false;
  uint32_t pressedSinceMs_ = 0;
  uint32_t lastPollMs_ = 0;
  uint32_t lastReconnectAttemptMs_ = 0;
  uint32_t lastErrorLogMs_ = 0;
  int32_t encoderPosition_ = 0;
};
