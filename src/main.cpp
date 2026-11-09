#include <Arduino.h>

#include "BoardConfig.h"
#include "ControlCoordinator.h"
#include "Encoder.h"
#include "MotorController.h"
#include "RemoteControl.h"
#include "RotaryControl.h"
#include "SerialConsole.h"

MotorController motor;
Encoder encoder;
ControlCoordinator control(motor);
SerialConsole console(motor, encoder, control);
RemoteControl remote(motor, encoder, control);
RotaryControl rotary(control, motor);

void setup() {
  // Motor safety is initialized before the serial console or encoder.
  motor.begin();
  control.begin();
  encoder.begin();

  Serial.begin(115200);
  delay(250);
  console.begin();
  rotary.begin();
  remote.begin();
}

void loop() {
  console.update();
  encoder.update();
  rotary.update();
  remote.update();
  control.update();
  delay(1);
}
