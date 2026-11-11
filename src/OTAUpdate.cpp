#include "OTAUpdate.h"

#include <Update.h>

#include "Secrets.h"
#include "WebDashboard.h"

namespace {
constexpr char kAuthenticationRealm[] = "Downhill Firmware Admin";
constexpr char kConfirmationHeader[] = "Downhill-Dispatcher";
constexpr uint32_t kUploadTimeoutMs = 10000;
constexpr uint32_t kRebootDelayMs = 1500;
}

void OTAUpdate::begin(BeginCallback onBegin) {
  onBegin_ = onBegin;
  const char* headers[] = {"Host", "Origin", "X-OTA-Confirm"};
  server_.collectHeaders(headers, 3);
  server_.on("/update", HTTP_GET, [this]() { handlePage(); });
  server_.on("/api/update", HTTP_POST,
             [this]() { handleUploadComplete(); },
             [this]() { handleUploadData(); });

  if (!credentialsConfigured()) {
    Serial.println(F("WARNING: OTA disabled; configure separate admin credentials in Secrets.h"));
  }
}

void OTAUpdate::update() {
  if (uploadAccepted_ && !uploadSucceeded_ &&
      millis() - lastChunkMs_ > kUploadTimeoutMs) {
    failUpload(F("upload timed out"), 408);
  }
  if (uploadSucceeded_ && rebootAtMs_ != 0 &&
      static_cast<int32_t>(millis() - rebootAtMs_) >= 0) {
    motor_.stop();
    Serial.println(F("OTA: verified update complete; rebooting"));
    ESP.restart();
  }
}

bool OTAUpdate::credentialsConfigured() const {
  return strlen(Secrets::kOtaUsername) > 0 &&
         strlen(Secrets::kOtaPassword) >= 12 &&
         strcmp(Secrets::kOtaPassword, Secrets::kApPassword) != 0 &&
         strcmp(Secrets::kOtaPassword,
                "replace-with-a-different-strong-password") != 0;
}

bool OTAUpdate::authenticateRequest() {
  if (!credentialsConfigured()) {
    sendJson(503, F("{\"ok\":false,\"error\":\"OTA administrator credentials are not configured\"}"));
    return false;
  }
  if (server_.authenticate(Secrets::kOtaUsername, Secrets::kOtaPassword)) {
    return true;
  }
  server_.requestAuthentication(BASIC_AUTH, kAuthenticationRealm,
                                F("Administrator authentication required"));
  return false;
}

bool OTAUpdate::validateUploadRequest() {
  const String host = server_.header("Host");
  const String expectedOrigin = String(F("http://")) + host;
  if (host.isEmpty() || server_.header("Origin") != expectedOrigin ||
      server_.header("X-OTA-Confirm") != kConfirmationHeader) {
    failUpload(F("same-origin firmware request required"), 403);
    return false;
  }
  return true;
}

void OTAUpdate::handlePage() {
  if (!authenticateRequest()) return;
  server_.sendHeader("Cache-Control", "no-store");
  server_.sendHeader("X-Frame-Options", "DENY");
  server_.sendHeader("Content-Security-Policy",
                     "default-src 'self'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; frame-ancestors 'none'");
  server_.send_P(200, "text/html", kOtaUpdatePage);
}

void OTAUpdate::handleUploadData() {
  HTTPUpload& upload = server_.upload();
  if (upload.status == UPLOAD_FILE_START) {
    requestAuthenticated_ = false;
    requestOriginAllowed_ = false;
    uploadAccepted_ = false;
    uploadSucceeded_ = false;
    bytesReceived_ = 0;
    maximumSize_ = 0;
    rebootAtMs_ = 0;
    responseStatus_ = 400;
    errorMessage_ = "";

    if (!credentialsConfigured()) {
      responseStatus_ = 503;
      errorMessage_ = F("OTA administrator credentials are not configured");
      return;
    }
    requestAuthenticated_ =
        server_.authenticate(Secrets::kOtaUsername, Secrets::kOtaPassword);
    if (!requestAuthenticated_) return;
    requestOriginAllowed_ = validateUploadRequest();
    if (!requestAuthenticated_ || !requestOriginAllowed_) return;

    String filename = upload.filename;
    filename.toLowerCase();
    if (upload.name != "firmware" || !filename.endsWith(".bin")) {
      failUpload(F("select a compiled .bin firmware file"));
      return;
    }
    if (motor_.isRunning() || !control_.beginFirmwareUpdate()) {
      failUpload(F("motor must be stopped before updating"), 409);
      return;
    }
    if (onBegin_) onBegin_();

    const size_t freeSketchSpace = ESP.getFreeSketchSpace();
    maximumSize_ = freeSketchSpace > 0x1000
                       ? (freeSketchSpace - 0x1000) & 0xFFFFF000
                       : 0;
    Update.clearError();
    if (maximumSize_ == 0 || !Update.begin(maximumSize_, U_FLASH)) {
      failUpload(String(F("cannot start update: ")) + Update.errorString(),
                 507);
      return;
    }
    uploadAccepted_ = true;
    lastChunkMs_ = millis();
    Serial.printf("OTA: receiving %s (maximum %u bytes)\n",
                  upload.filename.c_str(), static_cast<unsigned>(maximumSize_));
    return;
  }

  if (!uploadAccepted_) return;
  lastChunkMs_ = millis();

  if (upload.status == UPLOAD_FILE_WRITE) {
    if (upload.currentSize > maximumSize_ - bytesReceived_) {
      failUpload(F("firmware image exceeds the OTA slot"), 413);
      return;
    }
    if (Update.write(upload.buf, upload.currentSize) != upload.currentSize) {
      failUpload(String(F("flash write failed: ")) + Update.errorString(), 500);
      return;
    }
    bytesReceived_ += upload.currentSize;
  } else if (upload.status == UPLOAD_FILE_END) {
    if (bytesReceived_ == 0 || bytesReceived_ != upload.totalSize) {
      failUpload(F("firmware upload was incomplete"));
      return;
    }
    if (!Update.end(true)) {
      failUpload(String(F("firmware verification failed: ")) +
                     Update.errorString(),
                 422);
      return;
    }
    uploadAccepted_ = false;
    uploadSucceeded_ = true;
    responseStatus_ = 200;
    rebootAtMs_ = millis() + kRebootDelayMs;
    Serial.printf("OTA: verified %u-byte image; reboot scheduled\n",
                  static_cast<unsigned>(bytesReceived_));
  } else if (upload.status == UPLOAD_FILE_ABORTED) {
    failUpload(F("firmware upload was interrupted"));
  }
}

void OTAUpdate::handleUploadComplete() {
  if (!credentialsConfigured()) {
    sendJson(503, F("{\"ok\":false,\"error\":\"OTA administrator credentials are not configured\"}"));
    return;
  }
  if (!requestAuthenticated_) {
    server_.requestAuthentication(BASIC_AUTH, kAuthenticationRealm,
                                  F("Administrator authentication required"));
    return;
  }

  if (uploadSucceeded_) {
    sendJson(200, F("{\"ok\":true,\"message\":\"Firmware verified. Device is rebooting.\"}"));
    return;
  }
  String body = F("{\"ok\":false,\"error\":\"");
  body += errorMessage_.isEmpty() ? F("update failed") : errorMessage_;
  body += F("\"}");
  sendJson(responseStatus_, body);
}

void OTAUpdate::failUpload(const String& message, int statusCode) {
  if (Update.isRunning()) Update.abort();
  uploadAccepted_ = false;
  uploadSucceeded_ = false;
  responseStatus_ = statusCode;
  errorMessage_ = message;
  motor_.stop();
  control_.endFirmwareUpdate();
  Serial.print(F("OTA ERROR: "));
  Serial.println(message);
}

void OTAUpdate::sendJson(int statusCode, const String& body) {
  server_.sendHeader("Cache-Control", "no-store");
  server_.sendHeader("X-Content-Type-Options", "nosniff");
  server_.send(statusCode, "application/json", body);
}
