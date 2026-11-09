#include "SerialConsole.h"

#include "BoardConfig.h"

void SerialConsole::begin() {
  input_.reserve(64);
  Serial.println(F("Downhill Dispatcher ready; motor is SAFE/STOPPED."));
  printHelp();
}

void SerialConsole::update() {
  while (Serial.available() > 0) {
    const char c = static_cast<char>(Serial.read());
    if (c == '\n' || c == '\r') {
      if (!input_.isEmpty()) {
        execute(input_);
        input_ = "";
      }
    } else if (isPrintable(c) && input_.length() < 63) {
      input_ += c;
    }
  }
}

void SerialConsole::acknowledge() {
  control_.activity(ControlCoordinator::Source::Serial);
  Serial.println(F("OK"));
}

void SerialConsole::execute(String command) {
  command.trim();
  command.toLowerCase();

  if (command == "start") {
    if (motor_.speedPercent() == 0) {
      Serial.println(F("ERR speed is 0; use SPEED <1..100> first"));
      return;
    }
    if (!control_.start(ControlCoordinator::Source::Serial)) {
      Serial.println(F("ERR START blocked by physical STOP guard"));
      return;
    }
    acknowledge();
  } else if (command == "stop") {
    control_.stop(ControlCoordinator::Source::Serial, F("serial command"));
    acknowledge();
  } else if (command == "forward" || command == "fwd") {
    control_.setDirection(ControlCoordinator::Source::Serial,
                          MotorController::Direction::Forward);
    acknowledge();
  } else if (command == "reverse" || command == "rev") {
    control_.setDirection(ControlCoordinator::Source::Serial,
                          MotorController::Direction::Reverse);
    acknowledge();
  } else if (command.startsWith("speed ")) {
    const int value = command.substring(6).toInt();
    if (value < 0 || value > 100) {
      Serial.println(F("ERR speed range is 0..100"));
      return;
    }
    control_.setSpeedPercent(ControlCoordinator::Source::Serial,
                             static_cast<uint8_t>(value));
    acknowledge();
  } else if (command.startsWith("timeout ")) {
    const long value = command.substring(8).toInt();
    if (value < 500 || value > 30000) {
      Serial.println(F("ERR timeout range is 500..30000 ms"));
      return;
    }
    control_.setSerialTimeoutMs(static_cast<uint32_t>(value));
    acknowledge();
  } else if (command == "status") {
    control_.activity(ControlCoordinator::Source::Serial);
    printStatus();
  } else if (command == "help" || command == "?") {
    control_.activity(ControlCoordinator::Source::Serial);
    printHelp();
  } else {
    Serial.println(F("ERR unknown command; enter HELP"));
  }
}

void SerialConsole::printStatus() const {
  Serial.printf("state=%s direction=%s speed=%u%% rpm=%.1f count=%ld source=%s timeout=%lums\n",
                motor_.isRunning() ? "RUNNING" : "STOPPED",
                motor_.direction() == MotorController::Direction::Forward
                    ? "FORWARD"
                    : "REVERSE",
                motor_.speedPercent(), encoder_.rpm(),
                static_cast<long>(encoder_.count()),
                control_.sourceName(),
                static_cast<unsigned long>(control_.serialTimeoutMs()));
}

void SerialConsole::printHelp() const {
  Serial.println(F("Commands: START, STOP, FORWARD/FWD, REVERSE/REV,"));
  Serial.println(F("          SPEED <0..100>, TIMEOUT <500..30000>, STATUS, HELP"));
  Serial.println(F("Direction changes stop the motor and require a new START."));
}
