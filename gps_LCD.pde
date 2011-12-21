 #include <string.h>
 #include <ctype.h>
 #include <SoftwareSerial.h>

#define LCDtxPin 2
boolean bWrite=false;
boolean bLCD=false;
SoftwareSerial LCD = SoftwareSerial(7, LCDtxPin);
// since the LCD does not send data back to the Arduino, we should only define the txPin
const int LCDdelay=10;  // conservative, 2 actually works

// wbp: goto with row & column
void goTo(int row, int col) {
  LCD.print(0xFE, BYTE);   //command flag
  LCD.print((col + row*64 + 128), BYTE);    //position 
  delay(LCDdelay);
}
void clearLCD(){
  LCD.print(0xFE, BYTE);   //command flag
  LCD.print(0x01, BYTE);   //clear command.
  delay(LCDdelay);
}
void backlightOn() {  //turns on the backlight
  LCD.print(0x7C, BYTE);   //command flag for backlight stuff
  LCD.print(157, BYTE);    //light level.
  delay(LCDdelay);
}
void backlightOff(){  //turns off the backlight
  LCD.print(0x7C, BYTE);   //command flag for backlight stuff
  LCD.print(128, BYTE);     //light level for off.
   delay(LCDdelay);
}
void serCommand(){   //a general function to call the command flag for issuing all other commands   
  LCD.print(0xFE, BYTE);
}
 int ledPin = 13;                  // LED test pin
 int rxPin = 0;                    // RX PIN 
 int txPin = 1;                    // TX TX
 int byteGPS=-1;
 char buff[300] = "";
int test=0;
// char comandoGPR[7] = "$GPRMC";
 char GPSCommand[7] = "$GPGGA";
 int commaCnt=0;
 int buffCnt=0;

 void setup() {
   pinMode(LCDtxPin,OUTPUT);
   LCD.begin(9600);
   clearLCD();
   backlightOn();
   pinMode(ledPin, OUTPUT);       // Initialize LED pin
   pinMode(rxPin, INPUT);
   pinMode(txPin, OUTPUT);
   Serial.begin(4800);
   for (int i=0;i<300;i++){       // Initialize a buffer for received data
     buff[i]=' ';
   }   
 }
 void loop() {
   delay(100);
   digitalWrite(ledPin,LOW);
    byteGPS=Serial.read();
//          Serial.print(byteGPS,BYTE);
    if(byteGPS=='$'){
      commaCnt =0;
      buffCnt =0;
      for(int i = 0; i <300 ; i++){
        buff[i]=' '; 
      }
      bWrite=true;
      
    }
    
    if(bWrite){

         digitalWrite(ledPin,HIGH);
      if(byteGPS==','){
        commaCnt++;
      }
      if((commaCnt==0 || commaCnt==2 || commaCnt==3 || commaCnt== 4|| commaCnt==5)){
        buff[buffCnt]=byteGPS;
        buffCnt ++; 
        bLCD=true;
      }
      

      switch(commaCnt){
        
        case 1:
        Serial.println(commaCnt);
          for(int i =0; i<buffCnt;i++){
            Serial.print(buff[i],BYTE);
          }
          for(int i = 0 ; i <6 ;i++){
            if(buff[i] != GPSCommand[i]){
              bWrite=false;
                          commaCnt=0;
              break;
            }
          }
           for(int i = 0; i <300 ; i++){
              buff[i]=' '; 
            }

            buffCnt=0;
          break;
        case 2:
         for(int i = 0; i <300 ; i++){
              buff[i]=' '; 
            }
            buffCnt=0;
          break;
        case 4:
if(buffCnt !=0){
          goTo(0,0);
          LCD.print("La:");
          for(int i =0;i<buffCnt;i++){
            goTo(0,3+i);
            Serial.println(commaCnt);
            Serial.print(buff[i],BYTE);
            LCD.print(buff[i],BYTE);
          }
          for(int i = 0; i <300 ; i++){
            buff[i]=' '; 
          }
            buffCnt=0;
}
          break;
          
        case 6:
        if(buffCnt !=0){
          goTo(1,0);
          LCD.print("Lo:");
          for(int i =0;i<buffCnt;i++){
            goTo(1,3+i);
            Serial.println(commaCnt);
            Serial.print(buff[i],BYTE);
            LCD.print(buff[i],BYTE);
          }
          for(int i = 0; i <300 ; i++){
            buff[i]=' '; 
          }
            buffCnt=0;
        }
          break;
          case 7:
             for(int i = 0; i <300 ; i++){
              buff[i]=' '; 
            }
            buffCnt=0;
          break;
      }
      
      
    }
    
 }
