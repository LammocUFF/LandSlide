//////CODIGO SENSOR MOVIMENTO DE MASSA 27/02/2020
/* Versão simplificada.. sem SD e sem RTC.   para versão completa voltar para versão 8

/*Considerações:   O endereço de comunicação do RTC e do MPU6050 pode ser os mesmos 0x68.   
 * para mudar o endereço do MPU6050, deve-se conetar o pino AD0 PARA 3.3V. Isso fara com que 
 * o enderço do sensor mude para 0x69.
 * Para verificar todos os dispositivos conectados ao I2C (PINOS A4 E A5) utilize o código do link
 * https://gist.github.com/tfeldmann/5411375
 * Devem aparecer 3 endereços (dois pelo RTC e um pelo sensor - 0x69 - )
 * 
 * O código implementa um SD para guardar os dados coletados
 * 
 * O código implementa a função SLEEP DO ARDUINO
 */
////CODIGO MPU6050

// Pinagem Arduino UNO
// GND - GND
// VCC - 5 V
// SDA - A4
// SCL - A5

// Pinagem Arduino MEGA
// GND - GND
// VCC - 5 V
// SDA - 20
// SCL - 21

//Conexões CLOCK
// Ligar pino D2 para o pino SQW.  Isso permetira o uso da alarme do RTC para acordar o arduino


//Biblioteca necessária para controlar o MPU6050  UTILIZAR AS LIBRARIAS COMPARTILHADAS NO GOOGLE DRIVE

#include "I2Cdev.h"
#include "MPU6050.h"
#include "Wire.h"
#include <SD.h>

//Biblioteca do RTC

#include <DS3232RTC.h>      // https://github.com/JChristensen/DS3232RTC

//Sleep
#include <avr/sleep.h>//this AVR library contains the methods that controls the sleep modes
#define interruptPin 2 //Pin we are going to use to wake up the Arduino

const int time_interval=60;// Sets the wakeup intervall in minutes

// LORA RF

#include <SoftwareSerial.h>

SoftwareSerial loraSerial(5, 6); // TX, RX mUDANÇA PARA O EASYEAD

String turnOn = "on";
//String turnOff = "ofi";  //sensor antigo
String turnOff = "off"; //Novo sensor
MPU6050 sensor(0x69);  //Define o endereço 0x69 como o endereço do sensor MPU6050
int MinEspera=30;
int HoraEspera=1;
unsigned long TempoEspera=60000*MinEspera*HoraEspera;

// Init the DS3231 using the hardware interface
//DS3231  rtc(SDA, SCL); //SDA, SCL   

// Init a Time-data structure
//Time  t;

// Criando variavel MPU6050 sensor

//Declarando as Variaveis 

//Variaveis para angulo de inclinação

int INICIO=0;

int minVal=265;
int maxVal=402;

double x;
double y;
double z;

//Variaveis do Acelerometro e Giroscopio sem processar.
int axL, ay, az;
int gx, gy, gz;

// Variaveis para o calculo do angulo rotaçao 
long tempo_prev;
float dt;
float ang_x, ang_y;
float ang_x_prev, ang_y_prev;
float ax_m_s2,ay_m_s2,az_m_s2;

const int chipSelect = 4;  // Define o pin que ativa o cartão de memoria
const int LedIndicador=10;  //Led para mostrar problemas
// const int LedIndicador=3;  //Versão EasyEDA
 void setup() {
  Serial.begin(9600);    //Iniciando o monitor serial 9600
  
  pinMode(interruptPin,INPUT_PULLUP);//Set pin d2 to input using the buildin pullup resistor
  pinMode(LedIndicador,OUTPUT);
  delay(20);
  
  
  digitalWrite(LedIndicador,LOW);  //Desliga o LED do erro
  //Configuração od sensor
  Serial.println(F("Inicio"));
  delay(50);


  /******************************************
   * 
   * Configuração de RTC
   ******************************************
    //RTC.begin();  // Initialize the rtc object

    /*
     * Uncomment the block block to set the time on your RTC. Remember to comment it again 
     * otherwise you will set the time at everytime you upload the sketch
     *
     **
      
     
    tmElements_t tm;
    tm.Hour = 13;               // set the RTC to an arbitrary time
    tm.Minute = 5;
    tm.Second = 00;
    tm.Day = 21;
    tm.Month = 2;
    tm.Year = 2020 - 1970;      // tmElements_t.Year is the offset from 1970
    RTC.write(tm);              // set the RTC from the tm structure
     /*Block end * */
 
  
   /*
  Serial.println(F("Inicia config clock..."));
  setSyncProvider(RTC.get);   // the function to get the time from the RTC
  delay(50);
  if(timeStatus() != timeSet)
  {
    Serial.println(F("--Unable to sync with the RTC"));
    Piscar(3);
    digitalWrite(LedIndicador,LOW); // Liga o LED INDICADORPiscar(2);
  }
  else
  {
    Serial.println(F("RTC has set the system time"));
  }
  
  // initialize the alarms to known values, clear the alarm flags, clear the alarm interrupt flags
    RTC.alarmInterrupt(ALARM_1, false);
    RTC.alarmInterrupt(ALARM_2, false);
    RTC.setAlarm(ALM1_MATCH_DATE, 0, 0, 0, 1);
    RTC.setAlarm(ALM2_MATCH_DATE, 0, 0, 0, 1);
    RTC.alarm(ALARM_1);
    RTC.alarm(ALARM_2);

    RTC.squareWave(SQWAVE_NONE);


    
    time_t t; //create a temporary time variable so we can set the time and read the time from the RTC
    t=RTC.get();//Gets the current time of the RTC
    RTC.setAlarm(ALM1_MATCH_MINUTES , 0, minute(t)+time_interval, 0, 0);// Setting alarm 1 to go off 5 minutes from now
    // clear the alarm flag
    RTC.alarm(ALARM_1);
    // configure the INT/SQW pin for "interrupt" operation (disable square wave output)
    RTC.squareWave(SQWAVE_NONE);
    // enable interrupt output for Alarm 1
    RTC.alarmInterrupt(ALARM_1, true);  
    Serial.print(F("Alarme "));  
    Serial.print(time_interval);
    Serial.println(F(" minutos"));

    
    
/******************************************
   * 
   * Configuração de SENSOR
   ******************************************/  
   
  Serial.println(F("inicializando Sensor..."));
  sensor.initialize();
  TestarComunicaSensor();
  
/******************************************
   * 
   * Configuração de Cartão de memoria
   ******************************************  

  // Verifica se o cartão de memoria pode ser inicializado
  if (!SD.begin(chipSelect)) {
    Serial.println(F("Falha ao abrir o cartão / cartão não presente"));
    // don't do anything more:
    Piscar(4);
    digitalWrite(LedIndicador,HIGH); // Liga o LED INDICADOR    
    while (1);
  }
  Serial.println(F("Cartão inizializado..."));
  delay(1000);


  /******************************************
   * 
   * Iniciando o Lora 
   ******************************************/
  loraSerial.begin(9600); // Iniciando o Lora
  delay(1000);
}

void loop() {
  Serial.println(F("inicio Loop"));
  //digitalClockDisplay();
  
  if (INICIO==0)
  {   INICIO=1;
      for (int i = 0; i <= 3; i++) {
      LerAcelera(); //Faz as leituras do MPU6050.  Armazena as informações nas variaveis globais    
      delay(1000);
      PrintarInforma();  //Printa na tela as informações  
      delay(3000);
      }
  }
  else
  {
      LerAcelera(); //Faz as leituras do MPU6050.  Armazena as informações nas variaveis globais    
      delay(1000);
      PrintarInforma();  //Printa na tela as informações 
      delay(3000);
      LerAcelera(); //Faz as leituras do MPU6050.  Armazena as informações nas variaveis globais    
      delay(1000);
      PrintarInforma();  //Printa na tela as informações        
  }
  Serial.println(F("Aguardando tempo de leitura"));
  Serial.println(TempoEspera);
  delay(TempoEspera);
  Serial.println(F("FIM do tempo de leitura"));
  //Going_To_Sleep();   
}
/************************************************************************************/
/*
 * 
 * FUNÇÕES DE APOIO AO PROGRAMA
 * 
 */
/************************************************************************************/

void Going_To_Sleep(){
  
    Serial.println(F("Going to sleep..."));//Print message to serial monitor
    Serial.println(F("Sleep  Time:"));
    digitalClockDisplay();
    
    sleep_enable();//Enabling sleep mode
    attachInterrupt(0, wakeUp, LOW);//attaching a interrupt to pin d2
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);//Setting the sleep mode, in our case full sleep
    
    
    delay(1000);  //Tempo nescessario para o Arduino terminar todas as tarefas antes de DORMIR
    sleep_cpu();//Coloca o Arduino a dormir.. neste momento o Arduino para de executar o código nesta linha... 
    
    /*Segue o código que será executado assim o arduino acorde*/
   
    Atividades(); //Executa as atividades desejadas uma vez acordado  
 
  }

void wakeUp(){
  Serial.println(F("Interrupt Fired"));//Print message to serial monitor
  
  //GravarNoSD(); 
   sleep_disable();//Disable sleep mode
  detachInterrupt(0); //Removes the interrupt from pin 2;
 
}

/* *********************************************
 *  A função atividades é executada toda vez que o arduino acorda.
 *  ********************************************
 */
void Atividades(){
  Serial.println(F("Arduino Acordou!"));//next line of code executed after the interrupt     
  time_t t; //create a temporary time variable so we can set the time and read the time from the RTC
  int NovoMinuto=0;
  t=RTC.get();//Gets the current time of the RTC
  NovoMinuto=minute(t)+time_interval;
  if (NovoMinuto>60){
    NovoMinuto=NovoMinuto-60;
  }
  RTC.setAlarm(ALM1_MATCH_MINUTES , 0, NovoMinuto, 0, 0);
  Serial.println(F("WakeUp Time"));
  RTC.alarm(ALARM_1); //Ativa o alarme
  LerAcelera(); //Faz as leituras do MPU6050.  Armazena as informações nas variaveis globais
    
  PrintarInforma();  //Printa na tela as informações  

  GravarNoSD();
}

// Função para gravar os dados no cartão SD
void GravarNoSD()
{
  time_t t;// creates temp time variable
  t=RTC.get(); //gets current time from rtc
  // open the file. note that only one file can be open at a time,
  // so you have to close this one before opening another.
  File dataFile = SD.open("datalog.txt", FILE_WRITE);

  // if the file is available, write to it:
  if (dataFile) {
    dataFile.print(String(year(t)));
    dataFile.print(",");
    dataFile.print(month(t));
    dataFile.print(",");
    dataFile.print(day(t));
    dataFile.print(",");
    dataFile.print(hour(t));
    dataFile.print(",");
    dataFile.print(minute(t));
    dataFile.print(",");
    dataFile.print(String(axL));
    dataFile.print(",");
    dataFile.print(String(ay));
    dataFile.print(",");
    dataFile.print(String(az));
    dataFile.print(",");
    dataFile.print(String(gx));
    dataFile.print(",");
    dataFile.print(String(gy));
    dataFile.print(",");
    dataFile.println(String(gz));      
    dataFile.close();
    // print to the serial port too:
  }
  // if the file isn't open, pop up an error:
  else {
    Serial.println(F("error Abrindo o arquivo"));
    Piscar(4); //Erro ao abrir arquivo
    digitalWrite(LedIndicador,HIGH); // Liga o LED INDICADOR  
  }
}


/*Função para ler os valores da aceleração*/
void LerAcelera()  
{
  TestarComunicaSensor();
  
  //Ler os dados do Acelerometro 
  sensor.getAcceleration(&axL, &ay, &az);
  
  //Ler os dados do Giroscopio  
  sensor.getRotation(&gx, &gy, &gz);

  //Calculos 
  //Calcular os Angulos de Inclinaçao (X,Y,Z)
    int xAng = map(axL,minVal,maxVal,-90,90);
    int yAng = map(ay,minVal,maxVal,-90,90);
    int zAng = map(az,minVal,maxVal,-90,90);

       x= RAD_TO_DEG * (atan2(-yAng, -zAng)+PI);
       y= RAD_TO_DEG * (atan2(-xAng, -zAng)+PI);
       z= RAD_TO_DEG * (atan2(-yAng, -xAng)+PI);
   
  // Transformar os valores do acelerometro inicialmente lidos em bits para m/s²
  
   ax_m_s2 = axL * (9.810/16384.0);
   ay_m_s2 = ay * (9.810/16384.0);
   az_m_s2 = az * (9.810/16384.0);

  
  // Angulos de Rotaçao com filtro de interferencia 
  // Angulos com o acelerometro em radiano
  float acel_ang_x=atan(ay/sqrt(pow(axL,2) + pow(az,2)))*(180.0/PI);
  float acel_ang_y=atan(-axL/sqrt(pow(ay,2) + pow(az,2)))*(180.0/PI);

  //Calcular o angulo de rotaçao com o giroscopio e filtro de complemento

  
  ang_x = 0.980*(ang_x_prev+(gx/131)*dt) + 0.02*acel_ang_x;
  ang_y = 0.980*(ang_y_prev+(gy/131)*dt) + 0.02*acel_ang_y;

  //Substituindo od valores
}


void PrintarInforma()
{
  //digitalClockDisplay();
  // Mostrar os angulos (X,Y,Z)
  Serial.println(F(" Angulo de Inclinacao"));
  Serial.print(" X: "); Serial.print(x); Serial.print("º"); 
  Serial.print(" Y: ");  Serial.print(y); Serial.print("º");
  Serial.print(" Z: ");  Serial.print(z); Serial.println("º");
  
 // Mostrar os angulos de rotaçao Giroscopio
  Serial.println(F(" Angulo de Rotacao"));
  Serial.print(" X: "); Serial.print(ang_x);  Serial.print("º");
  Serial.print(" Y: "); Serial.print(ang_y); Serial.println("º");

 // Aceleraçoes Angulares
 
  Serial.println(F(" Aceleracao Angular"));
  Serial.print(" X:");Serial.print(ax_m_s2); Serial.print(" m/s2"); Serial.print("\t");
  Serial.print(" Y:");Serial.print(ay_m_s2); Serial.print(" m/s2");  Serial.print("\t");
  Serial.print(" Z:");Serial.print(az_m_s2); Serial.print(" m/s2"); Serial.println("\t");
  
  Serial.println(F(" Aceleracao Original"));
  Serial.print(" AX:");Serial.print(axL); Serial.print(" m/s2"); Serial.print("\t");
  Serial.print(" AY:");Serial.print(ay); Serial.print(" m/s2"); Serial.print("\t");
  Serial.print(" AZ:");Serial.print(az); Serial.print(" m/s2"); Serial.println("\t");
  Serial.println("  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -");
  
// Enviando Dados Lora RF

  loraSerial.print(turnOn);
  delay (10);
  loraSerial.print(turnOff);
  loraSerial.print(" ");
  //loraSerial.println("Dados Recebidos");
  //loraSerial.println("Aceleração (m/s²)"); 
  loraSerial.print(ax_m_s2); loraSerial.print("|"); loraSerial.print(ay_m_s2); loraSerial.print("|"); loraSerial.print(az_m_s2); loraSerial.print("|");
  //loraSerial.println("Ângulo de Inclinação (º)");
  loraSerial.print(x); loraSerial.print("|"); loraSerial.print(y); loraSerial.print("|"); loraSerial.print(z); loraSerial.print("|");
  //loraSerial.println("Ângulo de Rotação com Filtro"); 
  loraSerial.print(ang_x); loraSerial.print("|"); loraSerial.print(ang_y); loraSerial.println("\t");

  Serial.println("/n O que se esta enviado para o Lora /n");
  Serial.print(turnOn);
  delay (100);
  Serial.print(turnOff);
  Serial.print(" ");
  
  //loraSerial.println("Dados Recebidos");
  //loraSerial.println("Aceleração (m/s²)"); 
  Serial.print(ax_m_s2); Serial.print("|"); Serial.print(ay_m_s2); Serial.print("|"); Serial.print(az_m_s2); Serial.print("|");
  //loraSerial.println("Ângulo de Inclinação (º)");
  Serial.print(x); Serial.print("|"); Serial.print(y); Serial.print("|"); Serial.print(z); Serial.print("|");
  //loraSerial.println("Ângulo de Rotação com Filtro"); 
  Serial.print(ang_x); Serial.print("|"); Serial.print(ang_y); Serial.print("|");

  /*Serial.println (turnOn);
  delay(3000);
  loraSerial.print(turnOff);
  delay (10);
  Serial.println (turnOff);*/

  delay(3000);     
}

void digitalClockDisplay() //Printa o tempo na tela
{
    time_t t;// creates temp time variable
    t=RTC.get(); //gets current time from rtc
    
    // digital clock display of the time
    
    Serial.print(hour(t));
    Serial.print(':');
    Serial.print(minute(t));
    Serial.print(':');
    Serial.print(second(t));
    Serial.print(' ');
    Serial.print(day(t));
    Serial.print(' ');
    Serial.print(month(t));
    Serial.print(' ');
    Serial.print(year(t));
    Serial.println();
}
void Piscar(int Erro)
{
  for (int contador = 0; contador < Erro; contador++) 
  {
    digitalWrite(LedIndicador,HIGH);
    delay(200);
    digitalWrite(LedIndicador,LOW);
    delay(200);    
  }
}
void TestarComunicaSensor()
{
  if (sensor.testConnection())
  { 
    Serial.println(F("Sensor iniciado corretamente"));
  }
  else 
  {
    Serial.println(F("Erro ao iniciar o sensor"));
    Piscar(3);
    digitalWrite(LedIndicador,HIGH); // Liga o LED INDICADOR
    while(1);
  }
}

/* Versão original da função digitalClockDisplay 
 *  
void digitalClockDisplayOri()
{
    time_t t;// creates temp time variable
    t=RTC.get(); //gets current time from rtc
    
    // digital clock display of the time
    Serial.print(hour());
    printDigits(minute());
    printDigits(second());
    Serial.print(' ');
    Serial.print(day());
    Serial.print(' ');
    Serial.print(month());
    Serial.print(' ');
    Serial.print(year());
    Serial.println();
}

void printDigits(int digits)
{
    // utility function for digital clock display: prints preceding colon and leading 0
    Serial.print(':');
    if(digits < 10)
        Serial.print('0');
    Serial.print(digits);
}
*/
