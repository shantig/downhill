#pragma once

#include <Arduino.h>

namespace BoardConfig {

// Verified against Waveshare's official ugv_base_general example (ugv_config.h).
constexpr gpio_num_t kMotorPwm = GPIO_NUM_25;  // PWMA
constexpr gpio_num_t kMotorIn1 = GPIO_NUM_21;  // AIN1
constexpr gpio_num_t kMotorIn2 = GPIO_NUM_17;  // AIN2
constexpr gpio_num_t kEncoderA = GPIO_NUM_35;  // AENCA
constexpr gpio_num_t kEncoderB = GPIO_NUM_34;  // AENCB

// Waveshare's official firmware assigns the board I2C bus to these pins.
constexpr gpio_num_t kI2cSda = GPIO_NUM_32;
constexpr gpio_num_t kI2cScl = GPIO_NUM_33;
constexpr uint32_t kI2cFrequencyHz = 100000;
constexpr uint16_t kI2cTimeoutMs = 20;

constexpr uint8_t kAnoAddress = 0x49;
constexpr uint16_t kAnoProductId = 5740;
constexpr uint8_t kAnoSelectPin = 1;
constexpr uint8_t kAnoUpPin = 2;
constexpr uint8_t kAnoLeftPin = 3;
constexpr uint8_t kAnoDownPin = 4;
constexpr uint8_t kAnoRightPin = 5;

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
constexpr uint8_t kDefaultSpeedPercent = 60;
constexpr uint8_t kRotarySpeedStepPercent = 5;
constexpr uint32_t kButtonDebounceMs = 25;
constexpr uint32_t kButtonLongPressMs = 1000;
constexpr uint32_t kPhysicalStopGuardMs = 250;
constexpr uint32_t kAnoPollPeriodMs = 10;
constexpr uint32_t kAnoReconnectPeriodMs = 1000;
constexpr uint32_t kAnoErrorLogPeriodMs = 5000;
// Adafruit seesaw encoder counts decrease for the intended clockwise mounting.
// Confirm this sign during Stage A and change only this constant if necessary.
constexpr int8_t kAnoClockwisePositionSign = -1;

}  // namespace BoardConfig
