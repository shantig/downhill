#pragma once

#include <Arduino.h>

class Encoder {
 public:
  void begin();
  void update();
  float rpm() const { return rpm_; }
  int32_t count() const;

 private:
  static void IRAM_ATTR onPhaseARise();
  static volatile int32_t pulseCount_;
  static portMUX_TYPE mux_;

  int32_t lastCount_ = 0;
  uint32_t lastSampleMs_ = 0;
  float rpm_ = 0.0F;
};
