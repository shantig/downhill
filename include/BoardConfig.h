#pragma once

#include <Arduino.h>

namespace BoardConfig {

// Verified against Waveshare's official ugv_base_general example (ugv_config.h).
constexpr gpio_num_t kMotorPwm = GPIO_NUM_25;  // PWMA
constexpr gpio_num_t kMotorIn1 = GPIO_NUM_21;  // AIN1
constexpr gpio_num_t kMotorIn2 = GPIO_NUM_17;  // AIN2
constexpr gpio_num_t kEncoderA = GPIO_NUM_35;  // AENCA
constexpr gpio_num_t kEncoderB = GPIO_NUM_34;  // AENCB

constexpr uint8_t kPwmChannel = 5;
constexpr uint32_t kPwmFrequencyHz = 20000;
constexpr uint8_t kPwmResolutionBits = 8;
constexpr uint8_t kPwmMaximum = 255;

// Waveshare specifies 7 PPR at the motor and a 150:1 gearbox: 1050 PPR at
// the output shaft. This firmware counts rising edges on encoder phase A.
constexpr float kEncoderPulsesPerOutputRevolution = 1050.0F;
constexpr uint32_t kRpmSamplePeriodMs = 500;

constexpr uint32_t kDefaultCommandTimeoutMs = 3000;
constexpr uint32_t kRemoteHeartbeatTimeoutMs = 500;
constexpr uint32_t kDirectionDeadTimeMs = 20;
constexpr uint8_t kDefaultSpeedPercent = 20;

}  // namespace BoardConfig
