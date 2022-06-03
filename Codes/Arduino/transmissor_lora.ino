#include <SoftwareSerial.h>
  
SoftwareSerial loraSerial(2, 3); // TX, RX
 
String turnOn = "on";
String turnOff = "off";
 
 
void setup() {
  Serial.begin(9600);
  delay(10);
  loraSerial.begin(9600);
  delay(10);
   
}
 
void loop() {
 
  loraSerial.print(turnOn);
  delay (10);
  Serial.println (turnOn);
  delay(3000);
  loraSerial.print(turnOff);
  delay (10);
  Serial.println (turnOff);
  delay(3000);   
  }
