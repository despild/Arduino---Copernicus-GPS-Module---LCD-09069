 #include <string.h>
 #include <ctype.h>
 #include <SoftwareSerial.h>

#define LCDtxPin 8

SoftwareSerial LCD = SoftwareSerial(7, LCDtxPin);
// since the LCD does not send data back to the Arduino, we should only define the txPin
const int LCDdelay=10;  // conservative, 2 actually works
int loc=0;
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
 char linea[300] = "";
// char comandoGPR[7] = "$GPRMC";
 char comandoGPR[7] = "$GPGGA";
 int cont=0;
 int bien=0;
 int conta=0;
 int indices[15];
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
     linea[i]=' ';
   }   
 }
 void loop() {
//     selectLineOne();

//   digitalWrite(ledPin, LOW);
//   byteGPS = -1;
   byteGPS=Serial.read();         // Read a byte of the serial port
//   Serial.print(byteGPS,HEX);
   if (byteGPS == -1) {      // See if the port is empty yet
     digitalWrite(ledPin,LOW);
     delay(1000);

     delay(100); 
   } else {
//          digitalWrite(ledPin,HIGH);
     linea[conta]=byteGPS;        // If there is serial port data, it is put in the buffer
     conta++;                      
     Serial.print(byteGPS, BYTE); 
     goTo(loc/16,loc%16);
     LCD.print(byteGPS,BYTE);
     loc++;
     if(loc >32)
       loc=0;
     digitalWrite(ledPin, HIGH); 
     if (byteGPS==15){            // If the received byte is = to 13, end of transmission

       cont=0;
       bien=0;
       for (int i=1;i<7;i++){     // Verifies if the received command starts with $GPR
         if (linea[i]==comandoGPR[i-1]){
           bien++;
         }
       }
       if(bien==6){               // If yes, continue and process the data
         for (int i=0;i<300;i++){
           if (linea[i]==','){    // check for the position of the  "," separator
             indices[cont]=i;
             cont++;
           }
           if (linea[i]=='*'){    // ... and the "*"
             indices[14]=i;
             cont++;
           }
         }
         Serial.println("");      // ... and write to the serial port
         Serial.println("");
         Serial.println("---------------");
         for (int i=0;i<14;i++){
//           switch(i){
//             case 0 :Serial.print("Time in UTC (HhMmSs): ");break;
//             case 1 :Serial.print("Status (A=OK,V=KO): ");break;
//             case 2 :Serial.print("Latitude: ");break;
//             case 3 :Serial.print("Direction (N/S): ");break;
//             case 4 :Serial.print("Longitude: ");break;
//             case 5 :Serial.print("Direction (E/W): ");break;
//             case 6 :Serial.print("Velocity in knots: ");break;
//             case 7 :Serial.print("Heading in degrees: ");break;
//             case 8 :Serial.print("Date UTC (DdMmAa): ");break;
//             case 9 :Serial.print("Magnetic degrees: ");break;
//             case 10 :Serial.print("(E/W): ");break;
//             case 11 :Serial.print("Mode: ");break;
//             case 12 :Serial.print("Checksum: ");break;
//           }
           for (int j=indices[i];j<(indices[i+1]-1);j++){
             Serial.print(linea[j+1]); 
           }
           Serial.println("");
         }
         Serial.println("---------------");
       }
       conta=0;                    // Reset the buffer
       for (int i=0;i<300;i++){    //  
         linea[i]=' ';             
       }                 
     }
   }
 }
 
// 
// void selectLineOne(){  //puts the cursor at line 0 char 0.
//   mySerial.print(0xFE, BYTE);   //command flag
//   mySerial.print(128, BYTE);    //position
//   delay(10);
//}
//void selectLineTwo(){  //puts the cursor at line 0 char 0.
//   mySerial.print(0xFE, BYTE);   //command flag
//   mySerial.print(192, BYTE);    //position
//   delay(10);
//}
//void goTo(int position) { //position = line 1: 0-15, line 2: 16-31, 31+ defaults back to 0
//if (position<16){
//  mySerial.print(0xFE, BYTE);   //command flag
//              mySerial.print((position+128), BYTE);    //position
//}else if (position<32){
//  mySerial.print(0xFE, BYTE);   //command flag
//              mySerial.print((position+48+128), BYTE);    //position 
//} else { goTo(0); }
//   delay(10);
//}
//
//void clearLCD(){
//   mySerial.print(0xFE, BYTE);   //command flag
//   mySerial.print(0x01, BYTE);   //clear command.
//   delay(10);
//}
//void backlightOn(){  //turns on the backlight
//    mySerial.print(0x7C, BYTE);   //command flag for backlight stuff
//    mySerial.print(157, BYTE);    //light level.
//   delay(10);
//}
//void backlightOff(){  //turns off the backlight
//    mySerial.print(0x7C, BYTE);   //command flag for backlight stuff
//    mySerial.print(128, BYTE);     //light level for off.
//   delay(10);
//}
//void serCommand(){   //a general function to call the command flag for issuing all other commands   
//  mySerial.print(0xFE, BYTE);
//}
//

