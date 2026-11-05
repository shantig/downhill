#pragma once

#include <Arduino.h>

class MotorController {
 public:
  enum class Direction : uint8_t { Forward, Reverse };

  void begin();
  void start();
  void stop();
  void setDirection(Direction direction);
  void setSpeedPercent(uint8_t percent);

  bool isRunning() const { return running_; }
  Direction direction() const { return direction_; }
  uint8_t speedPercent() const { return speedPercent_; }

 private:
  void applyOutput();

  Direction direction_ = Direction::Forward;
  uint8_t speedPercent_ = 0;
  bool running_ = false;
};
