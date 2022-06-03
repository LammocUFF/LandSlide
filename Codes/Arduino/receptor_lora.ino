#include <SoftwareSerial.h>
 
#define LED1  13 
 
SoftwareSerial loraSerial(2, 3); // TX, RX
 
void setup() {
  pinMode(LED1, OUTPUT);
  Serial.begin(9600);
  loraSerial.begin(9600);  
}
 
void loop() { 
  if(loraSerial.available() > 1){
    String input = loraSerial.readString();
    Serial.println(input);  
    if(input == "on") {
      digitalWrite(LED1, HIGH);
      Serial.print("Ligando o Led");  
    } 
    if(input == "off") {
      digitalWrite(LED1, LOW);
      Serial.print("Desligando o Led");  
    }
    if(input == "offon") {
      digitalWrite(LED1, LOW);
      Serial.print("Deu Ruim");  
    }
  }
  delay(20);
  Serial.print (".");
}
