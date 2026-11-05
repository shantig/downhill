#include <Arduino.h>

#include "BoardConfig.h"
#include "Encoder.h"
#include "MotorController.h"
#include "RemoteControl.h"
#include "SerialConsole.h"

MotorController motor;
Encoder encoder;
SerialConsole console(motor, encoder);
RemoteControl remote(motor, encoder, console);

void setup() {
  // Motor safety is initialized before the serial console or encoder.
  motor.begin();
  motor.setSpeedPercent(BoardConfig::kDefaultSpeedPercent);
  encoder.begin();

  Serial.begin(115200);
  delay(250);
  console.begin();
  remote.begin();
}

void loop() {
  console.update();
  encoder.update();
  remote.update();
  console.checkTimeout();
  delay(1);
}
