#pragma once

#ifndef DOWNHILL_GIT_COMMIT
#define DOWNHILL_GIT_COMMIT "unknown"
#endif

namespace FirmwareInfo {

constexpr char kVersion[] = "1.1.0";
constexpr char kGitCommit[] = DOWNHILL_GIT_COMMIT;
constexpr char kBuildDate[] = __DATE__ " " __TIME__;

}  // namespace FirmwareInfo
