#pragma once

// Copy this file to include/Secrets.h and choose a unique password of at least
// 8 characters. Secrets.h is intentionally ignored by Git.
namespace Secrets {
constexpr char kApSsid[] = "Downhill-Dispatcher";
constexpr char kApPassword[] = "replace-with-a-strong-password";
// OTA credentials must be different from the SoftAP password. The firmware
// disables browser updates unless this password is at least 12 characters and
// no longer contains the placeholder below.
constexpr char kOtaUsername[] = "firmware-admin";
constexpr char kOtaPassword[] = "replace-with-a-different-strong-password";
}  // namespace Secrets
