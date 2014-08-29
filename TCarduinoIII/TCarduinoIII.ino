#include <Servo.h>
#include <IRremote.h>

int RECV_PIN = 11;
IRrecv irrecv(RECV_PIN);
IRsend irsend; // pin3 IR SEND

decode_results results;

#define DIGITAL_OUT_PIN        4
#define DIGITAL_OUT_PINII      5
#define DIGITAL_OUT_PINIII     6
#define DIGITAL_OUT_PINIV      7
#define SERVO_PIN              8

Servo myservo;


unsigned long currentMillis;        // store the current value from millis()
unsigned long previousMillis;       // for comparison with currentMillis
int samplingInterval = 250;          // how oftecommandon to run the main loop (in ms)


int receviedHit = 0;

float gunRangeVolume = 0.0;
int  currentGunID = 0;
int laserID = 1;
int catGunID = 2;
int gaterlingID =3;
boolean isGuninfoUpdate;

void setup()
{  
  pinMode(DIGITAL_OUT_PIN, OUTPUT);
  pinMode(DIGITAL_OUT_PINII, OUTPUT);
  pinMode(DIGITAL_OUT_PINIII, OUTPUT);
  pinMode(DIGITAL_OUT_PINIV, OUTPUT);

  myservo.attach(SERVO_PIN);

  //BLE Mini is connected to pin 0 and 1.
  Serial.begin(57600);

  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);

  irrecv.enableIRIn();
  isGuninfoUpdate = false;
}

void loop()
{
  static boolean hit_enabled = false;
  static boolean analog_enabled = false;
  static byte old_state = LOW;


  if (irrecv.decode(&results)) 
  {
    if( results.value == 0xA9)
    {
      if(receviedHit == 0)
      {
        receviedHit = 1;
      }
    }
    else if( results.value == 0xA8)
    {
      if(receviedHit == 0)
      {
        receviedHit = 2;
      }
    }
    else if( results.value == 0xA7)
    {
      if(receviedHit == 0)
      {
        receviedHit = 3;
      }
    }
    irrecv.resume(); // Receive the next value
    delay(10);
  }


  // If data is ready
  while (Serial.available())
  {    
    delay(10);
   // gunRangeVolume =  analogRead(A0);

    // read out command and data
    byte data0 = Serial.read();
    byte data1 = Serial.read();
    byte data2 = Serial.read();


    myservo.write(data2);
    if (data0 == 0x01)  // Command is to control digital out pin
    {
      if(data1 == 0x01)
      {
        digitalWrite(DIGITAL_OUT_PIN, LOW);
        digitalWrite(DIGITAL_OUT_PINIV, HIGH);
        delay(250);
        digitalWrite(DIGITAL_OUT_PINIV, LOW);
        delay(10);
        data1 = 0x00;
        data0 = 0x00;
      }
      else if(data1 == 0x02)
      {
        digitalWrite(DIGITAL_OUT_PINIV, LOW);
        digitalWrite(DIGITAL_OUT_PIN, HIGH);
        delay(250);
        digitalWrite(DIGITAL_OUT_PIN, LOW);
        delay(10);
        data1 = 0x00;
        data0 = 0x00;
      }
    } 
    else if(data0 == 0x02) {
      if(data1 == 0x01)
      {
        for (int i = 0; i < 3; i++) {
        irsend.sendSony(0xA9, 12); // Sony TV power code
        digitalWrite(DIGITAL_OUT_PINII, HIGH);
        digitalWrite(DIGITAL_OUT_PINIII, HIGH);
        delay(40);
        }
        digitalWrite(DIGITAL_OUT_PINII, LOW);
        digitalWrite(DIGITAL_OUT_PINIII, LOW);
        delay(50);
        data1 = 0x00;
        data0 = 0x00;
        irrecv.enableIRIn();     
      }
    }

/*
    else if ((data0) == 0xA9) // Command is to enable analog in reading
    {
      if (data1 == 0x01)
        analog_enabled = true;
      else
        analog_enabled = false;
    }
    */
    if(receviedHit > 0)
    {
      
      Serial.write((byte)0x0A);
          Serial.write((byte)0x01);
          Serial.write((byte)0x00);
          receviedHit = 0;
         // Serial.println("Sent Hit to ios");
          delay(20);
    }
    else
    {
      Serial.write((byte)0x0A);
      Serial.write((byte)0x00);
      Serial.write((byte)0x00);
    }
    
    
    /*
    if(gunRangeVolume > 650.0 && gunRangeVolume < 750.0 )
  {
    
      if(currentGunID != laserID)
      {
        isGuninfoUpdate = true;
        currentGunID = laserID;
      }
  }
  else if (gunRangeVolume >= 8.0)
  {
   if(currentGunID != catGunID)
      {
        isGuninfoUpdate = true;
        currentGunID = catGunID;
      }
  }
  else if (gunRangeVolume >=6.0)
  {
       if(currentGunID != gaterlingID)
      {
        isGuninfoUpdate = true;
        currentGunID = gaterlingID;
      }
  }
  */
  
  /*
  if(isGuninfoUpdate)
  {
   Serial.write((byte)0x0B);
    switch(currentGunID)
   {
     case 1:
       Serial.write((byte)0x01);
       break;
      case 2:
       Serial.write((byte)0x02);
       break;
      case 3:
       Serial.write((byte)0x03);
       break;    
   } 
   Serial.write((byte)0x00); 
   isGuninfoUpdate = false;
  }
  */
    
  }  
}


