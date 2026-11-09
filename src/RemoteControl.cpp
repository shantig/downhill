#include "RemoteControl.h"

#include <WiFi.h>

#include "BoardConfig.h"
#include "Secrets.h"
#include "WebDashboard.h"

namespace {
constexpr uint8_t kApChannel = 6;
constexpr uint8_t kMaximumClients = 4;

bool isUnsignedDecimal(const String& value) {
  if (value.isEmpty()) return false;
  for (size_t i = 0; i < value.length(); ++i) {
    if (!isDigit(value[i])) return false;
  }
  return true;
}
}

void RemoteControl::begin() {
  // begin() is called only after MotorController::begin(), and defensively
  // stops again before enabling any network interface.
  motor_.stop();
  remoteLeaseActive_ = false;

  WiFi.mode(WIFI_AP);
  if (!WiFi.softAP(Secrets::kApSsid, Secrets::kApPassword, kApChannel, false,
                   kMaximumClients)) {
    Serial.println(F("ERROR: SoftAP failed; browser control unavailable"));
    return;
  }

  configureRoutes();
  server_.begin();
  Serial.printf("SoftAP: %s\nDashboard: http://%s/\n", Secrets::kApSsid,
                WiFi.softAPIP().toString().c_str());
}

void RemoteControl::update() {
  if (remoteLeaseActive_ &&
      control_.source() != ControlCoordinator::Source::Web) {
    remoteLeaseActive_ = false;
    ++remoteStops_;
    Serial.println(F("REMOTE LEASE: ended by control ownership change"));
  }
  server_.handleClient();
  if (remoteLeaseActive_ &&
      millis() - lastHeartbeatMs_ > BoardConfig::kRemoteHeartbeatTimeoutMs) {
    stopRemote(F("heartbeat timeout"));
  }
}

void RemoteControl::configureRoutes() {
  server_.on("/", HTTP_GET, [this]() {
    server_.sendHeader("Cache-Control", "no-store");
    server_.send_P(200, "text/html", kWebDashboard);
  });
  server_.on("/api/status", HTTP_GET, [this]() { handleStatus(); });
  server_.on("/api/diagnostics", HTTP_GET,
             [this]() { handleDiagnostics(); });
  server_.on("/api/speed", HTTP_POST, [this]() { handleSpeed(); });
  server_.on("/api/direction", HTTP_POST, [this]() { handleDirection(); });
  server_.on("/api/run", HTTP_POST, [this]() { handleRun(); });
  server_.on("/api/heartbeat", HTTP_POST,
             [this]() { handleHeartbeat(); });
  server_.on("/api/stop", HTTP_POST, [this]() { handleStop(); });
  server_.onNotFound([this]() {
    sendJson(404, F("{\"ok\":false,\"error\":\"not found\"}"));
  });
}

void RemoteControl::sendJson(int statusCode, const String& body) {
  server_.sendHeader("Cache-Control", "no-store");
  server_.send(statusCode, "application/json", body);
}

bool RemoteControl::requireArgument(const char* name) {
  if (server_.hasArg(name)) {
    return true;
  }
  sendJson(400, String(F("{\"ok\":false,\"error\":\"missing ")) + name +
                    F("\"}"));
  return false;
}

bool RemoteControl::acceptRunCommandId() {
  if (!requireArgument("id")) return false;
  const String raw = server_.arg("id");
  if (!isUnsignedDecimal(raw)) {
    sendJson(400, F("{\"ok\":false,\"error\":\"invalid command id\"}"));
    return false;
  }
  const uint64_t id = strtoull(raw.c_str(), nullptr, 10);
  if (id <= lastRemoteCommandId_) {
    sendJson(409, F("{\"ok\":false,\"error\":\"stale run request\"}"));
    return false;
  }
  lastRemoteCommandId_ = id;
  return true;
}

void RemoteControl::observeCommandId() {
  if (!server_.hasArg("id")) return;
  const String raw = server_.arg("id");
  if (!isUnsignedDecimal(raw)) return;
  const uint64_t id = strtoull(raw.c_str(), nullptr, 10);
  if (id > lastRemoteCommandId_) lastRemoteCommandId_ = id;
}

void RemoteControl::handleStatus() {
  String body;
  body.reserve(180);
  body += F("{\"running\":");
  body += motor_.isRunning() ? F("true") : F("false");
  body += F(",\"speed\":");
  body += motor_.speedPercent();
  body += F(",\"direction\":\"");
  body += motor_.direction() == MotorController::Direction::Forward
              ? F("forward")
              : F("reverse");
  body += F("\",\"rpm\":");
  body += String(encoder_.rpm(), 1);
  body += F(",\"encoderCount\":");
  body += encoder_.count();
  body += F(",\"remoteLease\":");
  body += remoteLeaseActive_ ? F("true") : F("false");
  body += F(",\"source\":\"");
  body += control_.sourceName();
  body += F("\"");
  body += F(",\"anoConnected\":");
  body += rotary_.connected() ? F("true") : F("false");
  body += F("}");
  sendJson(200, body);
}

void RemoteControl::handleDiagnostics() {
  String body;
  body.reserve(180);
  body += F("{\"uptimeMs\":");
  body += millis();
  body += F(",\"freeHeap\":");
  body += ESP.getFreeHeap();
  body += F(",\"apIp\":\"");
  body += WiFi.softAPIP().toString();
  body += F("\",\"stations\":");
  body += WiFi.softAPgetStationNum();
  body += F(",\"remoteStops\":");
  body += remoteStops_;
  body += F(",\"heartbeatTimeoutMs\":");
  body += BoardConfig::kRemoteHeartbeatTimeoutMs;
  body += F("}");
  sendJson(200, body);
}

void RemoteControl::handleSpeed() {
  if (!requireArgument("value")) return;
  const String raw = server_.arg("value");
  const int value = raw.toInt();
  if (!isUnsignedDecimal(raw) || value < 0 || value > 100) {
    sendJson(400, F("{\"ok\":false,\"error\":\"speed must be 0..100\"}"));
    return;
  }
  control_.setSpeedPercent(ControlCoordinator::Source::Web,
                           static_cast<uint8_t>(value));
  if (value == 0 && remoteLeaseActive_) stopRemote(F("zero speed"));
  sendJson(200, F("{\"ok\":true}"));
}

void RemoteControl::handleDirection() {
  if (!requireArgument("value")) return;
  const String value = server_.arg("value");
  if (remoteLeaseActive_) stopRemote(F("direction change"));
  if (value == "forward") {
    control_.setDirection(ControlCoordinator::Source::Web,
                          MotorController::Direction::Forward);
  } else if (value == "reverse") {
    control_.setDirection(ControlCoordinator::Source::Web,
                          MotorController::Direction::Reverse);
  } else {
    sendJson(400, F("{\"ok\":false,\"error\":\"invalid direction\"}"));
    return;
  }
  sendJson(200, F("{\"ok\":true,\"running\":false}"));
}

void RemoteControl::handleRun() {
  if (!requireArgument("active")) return;
  if (server_.arg("active") != "1") {
    observeCommandId();
    stopRemote(F("hold released"));
    sendJson(200, F("{\"ok\":true,\"running\":false}"));
    return;
  }
  if (motor_.speedPercent() == 0) {
    sendJson(409, F("{\"ok\":false,\"error\":\"speed is zero\"}"));
    return;
  }
  if (!acceptRunCommandId()) return;

  // A fresh pointer-down request is the only path that starts a remote lease.
  // Heartbeats can maintain a lease but can never create or restart one.
  if (!control_.canStart(ControlCoordinator::Source::Web)) {
    sendJson(409, F("{\"ok\":false,\"error\":\"physical stop active\"}"));
    return;
  }
  remoteLeaseActive_ = true;
  lastHeartbeatMs_ = millis();
  if (!control_.start(ControlCoordinator::Source::Web)) {
    remoteLeaseActive_ = false;
    sendJson(409, F("{\"ok\":false,\"error\":\"run rejected\"}"));
    return;
  }
  sendJson(200, F("{\"ok\":true,\"running\":true}"));
}

void RemoteControl::handleHeartbeat() {
  if (!remoteLeaseActive_) {
    sendJson(409, F("{\"ok\":false,\"error\":\"no active lease\"}"));
    return;
  }
  lastHeartbeatMs_ = millis();
  control_.activity(ControlCoordinator::Source::Web);
  sendJson(200, F("{\"ok\":true}"));
}

void RemoteControl::handleStop() {
  // STOP is unconditional: it also stops motion started from the serial path.
  observeCommandId();
  stopRemote(F("remote stop"));
  sendJson(200, F("{\"ok\":true,\"running\":false}"));
}

void RemoteControl::stopRemote(const __FlashStringHelper* reason) {
  control_.stop(ControlCoordinator::Source::Web, reason);
  if (remoteLeaseActive_) {
    ++remoteStops_;
    Serial.print(F("REMOTE STOP: "));
    Serial.println(reason);
  }
  remoteLeaseActive_ = false;
}
