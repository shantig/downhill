#pragma once

#include <Arduino.h>
#include <WebServer.h>

#include "Encoder.h"
#include "MotorController.h"
#include "SerialConsole.h"

class RemoteControl {
 public:
  RemoteControl(MotorController& motor, Encoder& encoder,
                SerialConsole& console)
      : motor_(motor), encoder_(encoder), console_(console), server_(80) {}

  void begin();
  void update();
  bool hasActiveLease() const { return remoteLeaseActive_; }

 private:
  void configureRoutes();
  void handleStatus();
  void handleDiagnostics();
  void handleSpeed();
  void handleDirection();
  void handleRun();
  void handleHeartbeat();
  void handleStop();
  void stopRemote(const __FlashStringHelper* reason);
  void sendJson(int statusCode, const String& body);
  bool requireArgument(const char* name);
  bool acceptRunCommandId();
  void observeCommandId();

  MotorController& motor_;
  Encoder& encoder_;
  SerialConsole& console_;
  WebServer server_;
  bool remoteLeaseActive_ = false;
  uint32_t lastHeartbeatMs_ = 0;
  uint32_t remoteStops_ = 0;
  uint64_t lastRemoteCommandId_ = 0;
};
