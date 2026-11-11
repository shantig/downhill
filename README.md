# Downhill Dispatcher

PlatformIO firmware for safely commissioning and locally controlling one Waveshare
`DCGM-N20-12V-EN-200RPM` motor on Motor A of the Waveshare General Driver for
Robots. The user reports that the existing wired firmware rotates the 100 g
vertical auger; the wireless controller added here has **not** been validated on
hardware.

## Verified hardware facts

Sources checked on 2026-11-05:

- [Waveshare General Driver product page](https://www.waveshare.com/general-driver-for-robots.htm): ESP32-WROOM-32UE, TB6612FNG motor driver, encoder-capable Motor A/B ports, DC 7–13 V input.
- [Waveshare official firmware](https://github.com/waveshareteam/ugv_base_general/blob/main/General_Driver/ugv_config.h): Motor A is PWMA GPIO 25, AIN1 GPIO 21, AIN2 GPIO 17, AENCA GPIO 35, AENCB GPIO 34. Waveshare's positive Motor A convention is AIN1 low / AIN2 high.
- [Waveshare official firmware I2C configuration](https://github.com/waveshareteam/ugv_base_general/blob/main/General_Driver/ugv_config.h): SDA is GPIO 32 and SCL is GPIO 33.
- [Adafruit ANO Arduino guide](https://learn.adafruit.com/adafruit-ano-rotary-navigation-encoder-to-i2c-stemma-qt-adapter/arduino): seesaw address `0x49`, product ID 5740, SELECT/UP/LEFT/DOWN/RIGHT pins 1/2/3/4/5, and active-low buttons with seesaw pull-ups.
- [Waveshare motor product page](https://www.waveshare.com/dcgm-n20-12v-en-200rpm.htm): 12 V, 200 rpm no-load, <=0.1 A no-load, <=1.1 A locked-rotor, 150:1 reduction, AB Hall encoder, 7 PPR motor-side / 1050 PPR output-side, encoder accepts 3.3 V or 5 V.

The bench supply's observed 0.033 A idle draw is recorded as a baseline, not a
pass/fail result. A 1 A current limit is slightly below the motor's published
maximum locked-rotor current (1.1 A), which is useful protection but may trip
under startup or auger load.

GPIO 32/33 are the General Driver's published I2C bus and do not conflict with
Motor A or its encoder. Motor B uses GPIO 22/23/26/16/27, so the earlier plan to
use GPIO 26/27 for a bare encoder has been removed. The ANO adapter wiring and
disconnect behavior have not yet been bench-tested on the Rev1.2 board.

## First installation over USB

1. Install [VS Code](https://code.visualstudio.com/) and the PlatformIO extension, or PlatformIO Core.
2. Copy `include/Secrets.example.h` to `include/Secrets.h`. Set a unique SoftAP password and separate firmware-administrator username and password as described below.
3. Connect the board's USB Type-C port labeled for ESP32 communication (not the LIDAR Type-C port).
4. Leave the external 12 V motor supply switched off for the first flash.
5. Run `pio run`. The compiled upload image is `.pio/build/waveshare_general_driver/firmware.bin`.
6. Run `pio run --target upload`.
7. Open `pio device monitor --baud 115200` and reset the board. It must report `motor is SAFE/STOPPED` and must not report that OTA credentials are unconfigured.
8. If automatic upload does not begin, follow the Waveshare board's download-button procedure, then retry.

PlatformIO uses the generic `esp32dev` definition because the controller is an
ESP32-WROOM-32UE and Waveshare does not publish a dedicated PlatformIO board
manifest. The environment is pinned for reproducibility and resolves to
Arduino-ESP32 2.0.17. The official Adafruit seesaw library is pinned to 1.7.9;
its dependencies are resolved by PlatformIO.

The generic ESP32 board definition uses Arduino's standard 4 MB partition
layout. It provides two 1,310,720-byte application slots (`app0` and `app1`)
and an OTA metadata partition. The firmware can therefore be installed over
USB once and updated between slots afterward; no partition migration is
required. The build reports the exact image use and fails if it outgrows a
slot.

## Configure the private SoftAP

The firmware creates a WPA2-protected access point named
`Downhill-Dispatcher`; it does not need an internet connection or router.

1. Copy `include/Secrets.example.h` to `include/Secrets.h`.
2. Replace `kApPassword` with a unique password of at least eight characters.
3. Set `kOtaUsername` and a unique `kOtaPassword` of at least 12 characters.
   The OTA password must differ from the SoftAP password. Browser updating is
   disabled while the example placeholder remains.
4. Do not force-add `include/Secrets.h`: it is excluded by `.gitignore` so the
   credential cannot be committed accidentally.

A local `include/Secrets.h` is already present in this workspace for builds,
but all placeholder passwords must be changed before operating the motor or
using OTA.

## Subsequent browser firmware updates

Compile and install only binaries built for this exact project and board. OTA
streams the image into the inactive application slot; it does not buffer the
whole file in RAM. The installed firmware remains selected if upload or image
verification fails. Only a successfully verified image changes the boot slot.

### Build and share a binary

1. From the repository, run `pio run`.
2. Find the finished image at
   `.pio/build/waveshare_general_driver/firmware.bin`.
3. Rename a copy to include the version or commit if desired, while keeping the
   `.bin` extension.
4. Share it through a trusted private channel. A binary contains the configured
   SoftAP and OTA credentials, so anyone receiving it must protect it like a
   password.

The firmware page and dashboard show version `1.1.0`, build time, and the Git
commit embedded during compilation. Use these values to confirm the expected
build after reboot.

### Update instructions for an operator

1. Keep the controller on stable power. Make sure the motor says **STOPPED**;
   use the physical power cutoff if there is any doubt about the mechanism.
2. Join the `Downhill-Dispatcher` Wi-Fi network. It intentionally has no
   internet connection.
3. Open `http://192.168.4.1/`, scroll to **Firmware / System**, and choose
   **Open firmware updater**.
4. Enter the separate firmware-administrator username and password when the
   browser asks. The normal motor dashboard does not require these credentials.
5. Select the trusted `.bin` file, choose **Upload and install**, and confirm.
6. Do not close the page or remove power while progress is moving. The motor is
   locked off throughout the update.
7. After the success message, wait about 10 seconds, reconnect to the SoftAP if
   needed, and reload the dashboard.
8. Confirm the expected firmware version or Git commit and verify the state is
   **STOPPED**. The motor never resumes automatically.

An upload is refused if the motor is running, the file is not a `.bin`, the
image exceeds the inactive OTA slot, authentication fails, or the request did
not originate from the device's own authenticated update page. Update errors
are reported without rebooting.

### Recovery after an interrupted or failed update

- Keep power on until the page reports an error or the connection timeout has
  elapsed. The current firmware remains installed because the new slot is not
  selected until verification succeeds.
- Reconnect to `Downhill-Dispatcher`, reload the dashboard, confirm the motor is
  stopped, and retry with the correct binary.
- If the device rebooted, verify the displayed version. A failed image should
  still show the previous version.
- If the SoftAP or dashboard no longer appears after a power cycle, switch off
  the external motor supply and repeat the initial USB installation procedure.
  USB flashing is the recovery path for a corrupt or incompatible image.

### OTA security model

The SoftAP's WPA2 password controls network access. Firmware administration
then uses separate HTTP Basic credentials, same-origin validation, a required
custom confirmation header, and frame blocking. Both `/update` and
`/api/update` require administrator authentication. Credentials are compiled
from gitignored `include/Secrets.h`; there are no default working OTA
credentials.

HTTP itself is not TLS-encrypted. Use OTA only on the controller's private
SoftAP, with trusted nearby operators, unique passwords, and no bridged or
shared network. SoftAP-only mode has no upstream internet route, cloud service,
or automatic downloader, so a person must join the local Wi-Fi and upload a
file directly. This is why the device cannot be updated remotely over the
internet in its present configuration.

## GitHub Actions firmware artifact

`.github/workflows/firmware.yml` builds on pushes to `main` and manual workflow
runs. Before using it, configure the repository's Actions secrets
`AP_PASSWORD`, `OTA_USERNAME`, and `OTA_PASSWORD`. The workflow validates that
the passwords meet the firmware rules, creates the ignored `Secrets.h` only on
the runner, runs `pio run`, and retains `firmware.bin` as a downloadable
artifact for 30 days. Access to the repository artifact should be limited
because the compiled binary contains those device credentials.

## Connect from an iPhone or Mac

1. Flash the firmware over the board's ESP32 USB Type-C port with the 12 V motor
   supply switched off.
2. Open the serial monitor at 115200 baud. Confirm `motor is SAFE/STOPPED` and
   note the printed dashboard address (normally `http://192.168.4.1/`).
3. On iPhone, open **Settings > Wi-Fi**; on Mac, open the Wi-Fi menu. Join
   `Downhill-Dispatcher` with the password from `include/Secrets.h`.
4. The device may report that this network has no internet. Stay connected and
   browse to `http://192.168.4.1/` in Safari.
5. Confirm the dashboard says `Connected` and `STOPPED`. Joining Wi-Fi or
   reopening the page never starts the motor.

Only devices possessing the SoftAP password can reach the dashboard. HTTP is
local and unencrypted, so use a unique password and do not share the motor's
network while operating it.

## Wiring and power

1. Switch the bench output and the board power switch off.
2. Plug the motor's keyed 6-pin connector directly into the board's **Motor A 6P encoder** port. Do not use Motor B or either 2-pin non-encoder port.
3. Connect the bench supply to the board's XH2.54 power input with correct polarity: 12.0 V, initially limited to 1.0 A. Verify polarity with a meter before enabling output.
4. Keep USB connected for serial control. Do not separately wire encoder signals when using the keyed 6-pin cable.
5. Secure the unloaded motor so its shaft and cable cannot catch anything. For the auger test, add a guard and mechanically support the motor/auger assembly.

The encoder pins GPIO 34/35 cannot provide internal pull-ups. The specified
motor encoder contains pull-ups and the board's matched 6-pin connection is the
intended interface. If using a custom cable, first verify its pinout against
Waveshare's encoder connector diagram; do not infer wire function by color.

### Adafruit ANO #5001 with #5740 seesaw adapter

With all power off, wire the separate mechanical encoder as follows:

| ANO adapter connection | General Driver connection |
| --- | --- |
| VIN | 3.3 V |
| GND | Common GND |
| SDA | GPIO 32 / SDA |
| SCL | GPIO 33 / SCL |

The firmware starts `Wire` on GPIO 32/33 at 100 kHz with a 20 ms transaction
timeout, probes address `0x49`, verifies product ID 5740, enables seesaw input
pull-ups, and records the initial absolute encoder position without creating an
event. Clockwise changes speed +5% per reported step and counterclockwise -5%,
clamped to 0–100%. SELECT controls START/STOP, double-press direction reversal,
and long-press reset; the other four buttons currently log press/release
diagnostics only. The configured
encoder sign follows the expected ANO mounting but must be confirmed during
Stage A; if reversed, change `kAnoClockwisePositionSign` rather than rewiring
the I2C bus.

## Serial commands

Commands are case-insensitive and newline-terminated:

| Command | Behavior |
| --- | --- |
| `SPEED 20` | Set PWM duty to 20%; `0` also stops |
| `FORWARD` / `FWD` | Select Waveshare-positive direction and stop |
| `REVERSE` / `REV` | Select reverse direction and stop |
| `START` | Run at the selected speed/direction |
| `STOP` | Immediately set PWM to zero and coast |
| `STATUS` | Print state, direction, duty, measured RPM, count, timeout |
| `TIMEOUT 3000` | Set command watchdog in ms (500–30000) |
| `HELP` | Print command summary |

Startup is always stopped in reverse with a 60% speed preset. A direction change de-energizes Motor A, waits 20 ms,
changes direction, and requires a separate `START`. While running, no valid
command for 3 seconds triggers a stop. Reboot, malformed commands, and a zero
speed never start the motor.

## Browser control and safety model

The responsive dashboard shows run state, direction, PWM percentage, and live
encoder RPM. Its large run control must remain pressed. A pointer release,
cancelled touch, STOP press, hidden browser tab, page exit, offline event, or
missing heartbeat stops Motor A. The ESP32 enforces the 500 ms timeout; browser
events are additional early-stop paths.

A fresh hold gesture creates a remote-control lease. Heartbeats only extend an
existing lease and cannot create or restart one. Direction controls end the
lease and stop the bridge before changing direction. The remote STOP endpoint
always stops the motor, including motion started over serial. While a remote
lease is active, its 500 ms watchdog applies. Taking web ownership first safely
stops serial-owned motion, so the serial watchdog is never suspended or
extended. The physical board power switch remains the independent cutoff.

Physical, web, and serial commands share the same authoritative motor state.
The most recent deliberate command owns control (`PHYSICAL`, `WEB`, or
`SERIAL`), and every ownership change first performs a safe STOP. A physical
rotation can change a stopped preset or adjust speed while physical control is
already running; taking control from web or serial stops first. A short press
stops a running motor immediately; START waits for the 400 ms double-press
window. A double press stops and reverses direction; a separate short press is
required to restart. A press held for at least one second stops and resets the
preset to 60%, with no short-press action on release.

Serial-owned motion retains its configured 3-second command timeout. Web-owned
motion retains its 500 ms heartbeat lease. Physical control has no software
keepalive, but taking physical ownership never suspends or lengthens either
watchdog: it safely stops the previous owner first. A physical STOP cancels a
web lease. While the button is held, and briefly after a physical STOP, remote
and serial START requests are rejected. A button held during startup must be
released before it can create an event, and a long press cannot become a
short-press restart on release.

The ANO is polled every 10 ms using checked reads. A failed probe, encoder read,
or button read marks it disconnected; failed data is never interpreted as a
press. If PHYSICAL owns a running motor, detection of that failure immediately
commands STOP. The firmware makes a bounded reconnection attempt once per
second, validates product ID again, and re-baselines position and buttons;
serial and web operation remain available while the ANO is absent. Physical
restart then requires a fresh SELECT press. SELECT held during boot or
reconnection must first be released and cannot start the motor.

Firmware upload adds a fourth `UPDATE` ownership state. Its lock is enforced
inside the shared control coordinator, so physical SELECT, serial `START`, and
web run requests all use the same denial path. Starting an upload requires an
already stopped motor; the firmware then stops it defensively, revokes any web
lease, and retains the lock until failure cleanup or reboot. STOP commands
remain unconditional. Speed and direction changes are ignored while locked.
After either a failed update or a successful reboot, the motor remains stopped
and requires a new deliberate START action.

The built-in, loop-serviced `WebServer` keeps request handlers short and does no
blocking network waits. Useful endpoints are:

| Endpoint | Method | Purpose |
| --- | --- | --- |
| `/api/status` | GET | Live motor, encoder, source, ANO, and lease state |
| `/api/diagnostics` | GET | Uptime, free heap, AP IP, clients, stop count |
| `/api/speed?value=20` | POST | Set PWM percentage |
| `/api/direction?value=forward` | POST | Stop and select direction |
| `/api/run?active=1&id=...` | POST | Deliberately create a run lease |
| `/api/heartbeat` | POST | Maintain an existing run lease |
| `/api/stop` | POST | Unconditional stop |
| `/update` | GET | Authenticated firmware-administration page |
| `/api/update` | POST | Authenticated, same-origin streaming firmware upload |

## Staged hardware validation

No physical validation is claimed until these checks are completed and recorded.

### Stage A: motor disconnected

- Power by USB with Motor A disconnected. Confirm startup remains STOPPED.
- Confirm serial reports address `0x49`, product 5740, and an initial position;
  confirm the dashboard reports ANO connected.
- Turn both directions and compare position/delta logs. Confirm one 5% change
  per reported wheel step and the intended clockwise sign.
- Press and release SELECT, UP, DOWN, LEFT, and RIGHT; confirm each diagnostic.
- Confirm SELECT short press toggles, double press stops and reverses direction,
  and a >=1 second press stops and restores 60%, without a short-press action
  on release.
- Disconnect SDA, SCL, or the entire cable. Confirm disconnected status and no
  fabricated button event. Reconnect and confirm product/position revalidation.
- Reconnect or boot while holding SELECT. Release it and confirm no START; then
  require a new deliberate press.
- Exercise serial and web control with the motor disconnected. Confirm the
  3000 ms serial timeout, 500 ms web heartbeat, ownership transitions, and live
  dashboard speed/state/source/RPM/ANO updates.

### Stage B: motor connected

- Begin unloaded at low speed with the physical power cutoff accessible. Verify
  startup STOPPED, SELECT START/STOP, and live +/-5% speed changes.
- Start from web control, then press SELECT and confirm physical STOP takes
  ownership and cancels the web lease.
- Repeat serial timeout and web heartbeat-loss tests at low speed.
- While PHYSICAL owns a running motor, interrupt the ANO I2C connection and
  confirm immediate STOP on detected failure. Reconnect and confirm a fresh
  SELECT press is required before physical restart.
- Confirm dashboard synchronization throughout. Record voltage, current, RPM,
  direction, fault-detection latency, and all unexpected behavior.

### Stage C: OTA validation

Perform Stage C first with the auger mechanically disconnected or the motor
supply switched off. No hardware validation is claimed by this repository.

- Request `/update` without credentials and with incorrect credentials; confirm
  both the page and upload endpoint reject access.
- From a different web origin, attempt a form POST to `/api/update`; confirm the
  same-origin and confirmation-header checks reject it.
- Start the motor at low risk, attempt an authenticated update, and confirm the
  update is rejected and the motor is stopped. Confirm no flash/reboot occurs.
- With the motor stopped, upload a known-good build. During upload, attempt
  physical, serial, and web START commands and confirm all are rejected while
  STOP continues to work.
- Confirm progress reaches 100%, the device reboots only after verification,
  the expected version/commit appears, and startup remains STOPPED.
- Interrupt a second upload by disabling Wi-Fi or closing the browser. Keep
  device power on, reconnect, and confirm the previous known-good firmware still
  boots and the motor never starts.
- Upload a non-firmware `.bin`, a truncated image, an oversized image, and a
  renamed non-`.bin` file one at a time. Confirm each fails without selecting a
  new boot image or automatically starting the motor.
- Finally repeat a successful update with the motor connected but unloaded,
  physical power cutoff accessible, and all serial/dashboard safety checks
  observed.

## Implementation layout

- `include/BoardConfig.h`: verified GPIOs and tunable constants
- `src/MotorController.cpp`: bridge/PWM safety behavior
- `src/ControlCoordinator.cpp`: authoritative ownership and timeout behavior
- `src/RotaryControl.cpp`: checked seesaw encoder/button input and reconnect safety
- `src/Encoder.cpp`: signed pulse counting and RPM calculation
- `src/SerialConsole.cpp`: command parsing and diagnostics
- `src/RemoteControl.cpp`: SoftAP, HTTP API, and 500 ms remote lease
- `src/OTAUpdate.cpp`: authenticated streaming OTA and update-state handling
- `src/WebDashboard.cpp`: embedded responsive dashboard
- `include/FirmwareInfo.h`: displayed version, Git commit, and build metadata
- `scripts/firmware_version.py`: build-time Git commit injection
- `src/main.cpp`: minimal application wiring

Encoder RPM assumes Waveshare's published 1050 PPR output-shaft value while
counting phase-A rising edges. Compare displayed RPM to an independent tachometer
during commissioning; adjust the single constant in `BoardConfig.h` only if the
motor documentation or measured count-per-revolution proves a different edge
convention.

ESP-NOW is intentionally left as a future extension; it is not initialized or
required by this milestone.
