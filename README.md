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
- [Waveshare motor product page](https://www.waveshare.com/dcgm-n20-12v-en-200rpm.htm): 12 V, 200 rpm no-load, <=0.1 A no-load, <=1.1 A locked-rotor, 150:1 reduction, AB Hall encoder, 7 PPR motor-side / 1050 PPR output-side, encoder accepts 3.3 V or 5 V.

The bench supply's observed 0.033 A idle draw is recorded as a baseline, not a
pass/fail result. A 1 A current limit is slightly below the motor's published
maximum locked-rotor current (1.1 A), which is useful protection but may trip
under startup or auger load.

## Build and flash

1. Install [VS Code](https://code.visualstudio.com/) and the PlatformIO extension, or PlatformIO Core.
2. Connect the board's USB Type-C port labeled for ESP32 communication (not the LIDAR Type-C port).
3. Leave the external 12 V supply switched off for the first flash.
4. Run `pio run` and then `pio run --target upload`.
5. Open `pio device monitor --baud 115200` and reset the board. It must report `motor is SAFE/STOPPED`.
6. If automatic upload does not begin, follow the Waveshare board's download-button procedure, then retry.

PlatformIO uses the generic `esp32dev` definition because the controller is an
ESP32-WROOM-32UE and Waveshare does not publish a dedicated PlatformIO board
manifest. The environment is pinned for reproducibility and resolves to
Arduino-ESP32 2.0.17. It uses only the framework's Arduino, WiFi, and WebServer
libraries—no third-party dependencies.

## Configure the private SoftAP

The firmware creates a WPA2-protected access point named
`Downhill-Dispatcher`; it does not need an internet connection or router.

1. Copy `include/Secrets.example.h` to `include/Secrets.h`.
2. Replace `kApPassword` with a unique password of at least eight characters.
3. Do not force-add `include/Secrets.h`: it is excluded by `.gitignore` so the
   credential cannot be committed accidentally.

A local `include/Secrets.h` is already present in this workspace for builds,
but its placeholder password must be changed before operating the motor.

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

Startup is always stopped. A direction change de-energizes Motor A, waits 20 ms,
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
lease is active, its 500 ms watchdog supersedes the serial watchdog; when the
lease ends, the existing serial timeout resumes. The physical board power
switch remains the independent cutoff.

The built-in, loop-serviced `WebServer` keeps request handlers short and does no
blocking network waits. Useful endpoints are:

| Endpoint | Method | Purpose |
| --- | --- | --- |
| `/api/status` | GET | Live motor, encoder, and remote-lease state |
| `/api/diagnostics` | GET | Uptime, free heap, AP IP, clients, stop count |
| `/api/speed?value=20` | POST | Set PWM percentage |
| `/api/direction?value=forward` | POST | Stop and select direction |
| `/api/run?active=1&id=...` | POST | Deliberately create a run lease |
| `/api/heartbeat` | POST | Maintain an existing run lease |
| `/api/stop` | POST | Unconditional stop |

## Staged test procedure

### 1. Logic-only, motor disconnected

- Power by USB only. Confirm startup says stopped.
- Exercise `STATUS`, direction, speed, and `START`; after three seconds confirm the timeout message. The motor port must remain physically disconnected during this test.
- Reboot after issuing `START`; confirm it returns stopped.
- Join the SoftAP and load the dashboard from both the intended phone and Mac.
  Confirm status and diagnostics update, then press and release hold-to-run.
  With the motor still disconnected, verify the UI returns to stopped.
- Hold the run control and disable Wi-Fi, lock the phone, switch browser tabs,
  and close the page in separate trials. Each trial must show a remote-stop log
  no later than the 500 ms ESP32 watchdog bound.
- Reconnect after each trial and confirm the motor remains stopped until a new
  deliberate hold gesture. Verify the web STOP button also stops a serial
  `START` command.

### 2. Unloaded motor

- Start at `SPEED 10`, keep one hand at the bench-supply output control, then enable 12 V.
- Issue `START`, observe current, sound, direction, and `STATUS`; stop immediately on unexpected motion, heating, noise, encoder behavior, or current-limit operation.
- Raise duty in small steps. At full duty the unloaded speed should approach, but need not equal, the published 200 rpm. Confirm RPM sign reverses after `STOP`, `REV`, `START`.
- Record voltage, steady current, PWM percentage, RPM, and test duration. Do not mark the milestone hardware-validated until these observations are captured.
- Repeat release, Wi-Fi-loss, visibility-loss, heartbeat-timeout, direction,
  STOP, and reconnection checks at low PWM before increasing speed. Keep the
  physical power switch immediately accessible.

### 3. 100 g, 4-inch vertical auger

- Disconnect power before fitting the auger. Check shaft coupling, axial/radial support, balance, clearances, containment, and an accessible power cutoff.
- Keep people clear of the auger. Begin at the lowest duty that starts reliably and use short runs.
- Record startup and steady current, RPM, supply voltage, vibration, temperature, and whether the 1 A limit activates. Stop on a stall, coupling slip, excessive vibration, heating, or current limiting.
- Do not treat successful unloaded operation as evidence that the auger is safe or adequately supported.

## Implementation layout

- `include/BoardConfig.h`: verified GPIOs and tunable constants
- `src/MotorController.cpp`: bridge/PWM safety behavior
- `src/Encoder.cpp`: signed pulse counting and RPM calculation
- `src/SerialConsole.cpp`: command parsing and watchdog
- `src/RemoteControl.cpp`: SoftAP, HTTP API, and 500 ms remote lease
- `src/WebDashboard.cpp`: embedded responsive dashboard
- `src/main.cpp`: minimal application wiring

Encoder RPM assumes Waveshare's published 1050 PPR output-shaft value while
counting phase-A rising edges. Compare displayed RPM to an independent tachometer
during commissioning; adjust the single constant in `BoardConfig.h` only if the
motor documentation or measured count-per-revolution proves a different edge
convention.

ESP-NOW is intentionally left as a future extension; it is not initialized or
required by this milestone.
