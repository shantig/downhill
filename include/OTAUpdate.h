#pragma once

#include <Arduino.h>
#include <WebServer.h>

#include <functional>

#include "ControlCoordinator.h"
#include "MotorController.h"

class OTAUpdate {
 public:
  using BeginCallback = std::function<void()>;

  OTAUpdate(WebServer& server, MotorController& motor,
            ControlCoordinator& control)
      : server_(server), motor_(motor), control_(control) {}

  void begin(BeginCallback onBegin);
  void update();

 private:
  bool credentialsConfigured() const;
  bool authenticateRequest();
  bool validateUploadRequest();
  void handlePage();
  void handleUploadComplete();
  void handleUploadData();
  void failUpload(const String& message, int statusCode = 400);
  void sendJson(int statusCode, const String& body);

  WebServer& server_;
  MotorController& motor_;
  ControlCoordinator& control_;
  BeginCallback onBegin_;
  bool requestAuthenticated_ = false;
  bool requestOriginAllowed_ = false;
  bool uploadAccepted_ = false;
  bool uploadSucceeded_ = false;
  size_t bytesReceived_ = 0;
  size_t maximumSize_ = 0;
  uint32_t lastChunkMs_ = 0;
  uint32_t rebootAtMs_ = 0;
  int responseStatus_ = 400;
  String errorMessage_;
};
