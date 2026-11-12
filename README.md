# Downhill Dispatcher

Firmware for safely controlling one Waveshare `DCGM-N20-12V-EN-200RPM` motor
on Motor A of the Waveshare General Driver for Robots.

> **Latest recorded OTA update:** 2026-11-12 — v1.1.0 (`4d8e93db2410`). Keep
> the physical power cutoff within reach whenever operating the motor.

### Physical ANO controller

- Turn the knob: change speed by 5% per step.
- Short-press **SELECT**: start or stop.
- Double-press **SELECT**: stop and reverse direction.
- Hold **SELECT** for at least one second: stop and reset speed to 60%.

If the ANO controller disconnects while it owns a running motor, the firmware
stops the motor. A fresh press is required after reconnection.

## First installation over USB

Use the private `downhill-factory.bin` build artifact. It is a complete image
for offset `0x0`; `firmware.bin` is only for later browser updates.

1. In GitHub **Actions**, open a successful **Build firmware** run. Download
   and unzip the `downhill-dispatcher-<commit>` artifact.
2. Switch off the external 12 V motor supply.
3. Connect the board's ESP32 USB-C port—not the LIDAR port—with a data cable.
4. Open [ESPHome Web](https://web.esphome.io/) in Chrome or Edge.
5. Select **Connect**, choose the CP2102 serial device, then select **Install**.
6. Choose `downhill-factory.bin` and wait for installation to finish.
7. Join **Downhill-Dispatcher**, open <http://192.168.4.1/>, and verify
   **STOPPED** before restoring motor power.

If the board is not listed, try another data cable or USB port and install the
CP210x driver if needed. If flashing will not start, put the board in download
mode using Waveshare's download-button procedure and retry.

The binaries contain Wi-Fi and administrator credentials. Keep artifacts
private; do not publish them in a release or unauthenticated download.

## Browser firmware update

Use only `firmware.bin` built for this project and board.

1. Confirm the dashboard shows **STOPPED** and keep the controller on stable
   power.
2. Join **Downhill-Dispatcher** and open <http://192.168.4.1/>.
3. Under **Firmware / System**, select **Open firmware updater**.
4. Enter the firmware-administrator credentials.
5. Choose `firmware.bin`, then select **Upload and install**.
6. Keep the page open and power connected until the upload succeeds.
7. Wait about 10 seconds, reconnect if necessary, and verify the displayed
   version or commit and the **STOPPED** state.

The motor is locked off during an update. A failed upload leaves the current
firmware selected. If the dashboard does not return after a power cycle,
switch off motor power and repeat the USB installation.

OTA is available only on the device's local SoftAP. HTTP is not TLS-encrypted,
so use unique passwords and allow only trusted nearby operators.

## Wiring and power

With all power off:

1. Connect the motor's keyed 6-pin plug to **Motor A 6P encoder**. Do not use
   Motor B or either 2-pin motor port.
2. Connect the bench supply to the XH2.54 input with verified polarity. Start
   at **12.0 V / 1.0 A**.
3. Secure the unloaded motor. Guard and support the motor/auger assembly before
   testing under load.

The motor's encoder uses the keyed cable; do not wire its signals separately.
For a custom cable, verify the pinout from Waveshare documentation rather than
inferring it from wire colors.

### Adafruit ANO #5001 and seesaw #5740

| ANO adapter | General Driver |
| --- | --- |
| VIN | 3.3 V |
| GND | GND |
| SDA | GPIO 32 / SDA |
| SCL | GPIO 33 / SCL |

The adapter must appear at I2C address `0x49` with product ID 5740. If knob
direction is reversed, change `kAnoClockwisePositionSign`; do not swap I2C
wires.

## Build locally

Requirements: VS Code with PlatformIO, or PlatformIO Core.

1. Copy `include/Secrets.example.h` to `include/Secrets.h`.
2. Set a unique SoftAP password of at least 8 characters.
3. Set a separate OTA username and password of at least 12 characters.
4. Build with `pio run`.

Useful commands:

```text
pio run                                      # build OTA firmware
pio run --target upload                      # flash through USB
pio device monitor --baud 115200             # open serial console
pio run --target idedata
python scripts/build_factory_image.py        # build factory image
```

Build outputs:

- `.pio/build/waveshare_general_driver/firmware.bin`: browser OTA image.
- `.pio/build/waveshare_general_driver/downhill-factory.bin`: full USB image.

`include/Secrets.h` is ignored by Git. Never force-add it. The build uses the
generic `esp32dev` definition and a pinned Arduino-ESP32 2.0.17 environment.
The factory-image script validates the flash layout and merged image.

## Serial commands

Commands are case-insensitive and end with a newline.

| Command | Action |
| --- | --- |
| `SPEED 20` | Set speed to 20%; zero also stops |
| `FORWARD` or `FWD` | Stop and select forward |
| `REVERSE` or `REV` | Stop and select reverse |
| `START` | Run at the selected speed and direction |
| `STOP` | Stop immediately and coast |
| `STATUS` | Show state, direction, speed, RPM, and timeout |
| `TIMEOUT 3000` | Set watchdog to 500–30000 ms |
| `HELP` | Show command help |

Startup defaults to reverse at 60%, but remains stopped. While serial control
is running, three seconds without a valid command triggers a stop.

## Safety behavior

- Web control requires a continuous hold and a valid 500 ms heartbeat lease.
- Serial control uses a configurable watchdog, initially 3000 ms.
- Physical, web, and serial controls share one motor state. Taking ownership
  from another control source stops the motor first.
- STOP is unconditional. Direction changes, zero speed, restart, malformed
  commands, ANO failure during physical control, and firmware updates cannot
  start the motor.
- Firmware updates require a stopped motor and reject all start, speed, and
  direction requests until failure cleanup or reboot.
- The physical board power switch is the independent cutoff.

The dashboard exposes these local endpoints:

| Endpoint | Method | Purpose |
| --- | --- | --- |
| `/api/status` | GET | Motor, encoder, owner, ANO, and lease state |
| `/api/diagnostics` | GET | Uptime, heap, network, and stop count |
| `/api/speed?value=20` | POST | Set speed percentage |
| `/api/direction?value=forward` | POST | Stop and select direction |
| `/api/run?active=1&id=...` | POST | Create a web run lease |
| `/api/heartbeat` | POST | Maintain the lease |
| `/api/stop` | POST | Stop unconditionally |
| `/update` | GET | Authenticated updater |
| `/api/update` | POST | Authenticated firmware upload |

## Hardware validation checklist

No full physical validation is claimed until these checks are completed and
recorded.

### A. Motor disconnected

- Confirm boot state is **STOPPED**.
- Verify ANO address `0x49`, product 5740, knob direction, 5% steps, and all
  SELECT gestures.
- Disconnect and reconnect ANO wiring; confirm no false input or automatic
  restart.
- Verify the 3000 ms serial watchdog, 500 ms web lease, and ownership changes.

### B. Motor connected and unloaded

- Begin at low speed with the physical cutoff accessible.
- Verify physical, browser, and serial start/stop behavior.
- Take physical control during web operation and confirm an immediate stop.
- Disconnect the ANO during physical operation and confirm an immediate stop.
- Record voltage, current, RPM, direction, stop latency, and anomalies.

### C. Browser update

Start with motor power off or the auger disconnected.

- Verify missing or incorrect credentials and cross-origin uploads are denied.
- Attempt an update while running; confirm it stops the motor and is rejected.
- During a valid update, confirm every control source is unable to start it.
- Verify successful, interrupted, invalid, truncated, and oversized uploads all
  leave the motor stopped and preserve the previous image when verification
  fails.

## Hardware reference

Verified against vendor documentation on 2026-11-05:

- Controller: ESP32-WROOM-32UE, TB6612FNG, 7–13 V input.
- Motor A: PWMA 25, AIN1 21, AIN2 17, AENCA 35, AENCB 34.
- I2C: SDA 32, SCL 33.
- Motor: 12 V, 200 rpm no-load, at most 0.1 A no-load, at most 1.1 A
  locked-rotor, 150:1 reduction, 1050 PPR output-side encoder.
- ANO seesaw: address `0x49`, product 5740, buttons on pins 1–5.

Sources: [Waveshare General Driver](https://www.waveshare.com/general-driver-for-robots.htm),
[Waveshare firmware](https://github.com/waveshareteam/ugv_base_general/blob/main/General_Driver/ugv_config.h),
[Waveshare motor](https://www.waveshare.com/dcgm-n20-12v-en-200rpm.htm), and
[Adafruit ANO guide](https://learn.adafruit.com/adafruit-ano-rotary-navigation-encoder-to-i2c-stemma-qt-adapter/arduino).

The observed 0.033 A idle draw is a baseline, not a pass/fail threshold. The
1.0 A supply limit is below the published 1.1 A locked-rotor current and may
trip during startup or under auger load.

## Project layout

- `include/BoardConfig.h`: pins and tunable constants
- `src/MotorController.cpp`: motor bridge and PWM safety
- `src/ControlCoordinator.cpp`: ownership and watchdogs
- `src/RotaryControl.cpp`: ANO input and reconnection safety
- `src/Encoder.cpp`: pulse counting and RPM
- `src/SerialConsole.cpp`: serial commands
- `src/RemoteControl.cpp`: SoftAP, API, and web lease
- `src/OTAUpdate.cpp`: authenticated streaming updates
- `src/WebDashboard.cpp`: browser dashboard
- `src/main.cpp`: application wiring

RPM uses Waveshare's published 1050 PPR output-shaft value while counting phase
A rising edges. Confirm it with a tachometer before changing the constant in
`BoardConfig.h`. ESP-NOW is reserved for future work and is not initialized.
