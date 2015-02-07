/**
 * iFallLamp.ino - This is the basic lamp controller.  It is a mixture
 * of two samples, one from RFDuino the other from the LED Strip.
 */
#include "LPD8806.h"
#include "SPI.h" // Comment out this line if using Trinket or Gemma
#ifdef __AVR_ATtiny85__
#include <avr/power.h>
#endif

#include <RFduinoBLE.h>

// a count
int nLEDs = 32;

// a state
bool lightsOn = false;

// Pins
int clockPin = 0;
int dataPin  = 1;
int led1 = 2;
int led2 = 3;
int led3 = 4;
int button = 5;

uint8_t red = 255;
uint8_t green = 255;
uint8_t blue = 255;

// debounce time (in ms)
int debounce_time = 10;

// maximum debounce timeout (in ms)
int debounce_timeout = 100;

// First parameter is the number of LEDs in the strand.  The LED strips
// are 32 LEDs per meter but you can extend or cut the strip.  Next two
// parameters are SPI data and clock pins:
LPD8806 strip = LPD8806(nLEDs, dataPin, clockPin);

// You can optionally use hardware SPI for faster writes, just leave out
// the data and clock pin parameters.  But this does limit use to very
// specific pins on the Arduino.  For "classic" Arduinos (Uno, Duemilanove,
// etc.), data = pin 11, clock = pin 13.  For Arduino Mega, data = pin 51,
// clock = pin 52.  For 32u4 Breakout Board+ and Teensy, data = pin B2,
// clock = pin B1.  For Leonardo, this can ONLY be done on the ICSP pins.
//LPD8806 strip = LPD8806(nLEDs);

void setup() {
#if defined(__AVR_ATtiny85__) && (F_CPU == 16000000L)
  clock_prescale_set(clock_div_1); // Enable 16 MHz on Trinket
#endif

  // Start up the LED strip
  strip.begin();

  pinMode(led1, OUTPUT);
  pinMode(led2, OUTPUT);
  pinMode(led3, OUTPUT);

  pinMode(button, INPUT);

  // this is the data we want to appear in the advertisement
  // (if the deviceName and advertisementData are too long to fix into the 31 byte
  // ble advertisement packet, then the advertisementData is truncated first down to
  // a single byte, then it will truncate the deviceName)
  RFduinoBLE.advertisementData = "iFalLamp";

  // start the BLE stack
  RFduinoBLE.begin();

  digitalWrite(led1, LOW);
  digitalWrite(led2, LOW);
  digitalWrite(led3, LOW);
  allLightsOn(false);
}


void loop() {
  //  RFduino_ULPDelay(INFINITE);
  delay_until_button(HIGH);
}

void allLightsOn(bool on) {
  int i;
  int r = red;
  int g = green;
  int b = blue;

  lightsOn = on;

  if (!on) {
    r = 0;
    g = 0;
    b = 0;
  }

  // for (i = 0; i < strip.numPixels(); i++) {
  for (i = strip.numPixels() - 1; i >= 0; i--) {
    strip.setPixelColor(i, strip.Color(r, g, b));
    strip.show();
  }
  analogWrite(led1, r);
  analogWrite(led2, g);
  analogWrite(led3, b);
}

void RFduinoBLE_onConnect() {
  // the default starting color on the iPhone is white
  analogWrite(led1, 255);
  analogWrite(led2, 255);
  analogWrite(led3, 255);
  allLightsOn(true);
}

void RFduinoBLE_onDisconnect() {
  // turn all leds off on disconnect and stop pwm
  digitalWrite(led1, LOW);
  digitalWrite(led2, LOW);
  digitalWrite(led3, LOW);
  allLightsOn(false);
}

void RFduinoBLE_onReceive(char *data, int len) {
  int i; // = strip.numPixels() - 1;

  // each transmission should contain an RGB triple
  if (len >= 3)
  {

    lightsOn = true;
    // get the RGB values
    uint8_t r = data[0];
    uint8_t g = data[1];
    uint8_t b = data[2];

    red = r;
    green = g;
    blue = b;

    if (red == 6 && green == 6 && blue == 6) {
      rainbow(10);
      return;
    }
    if (red == 1 && green == 2 && blue == 3) {
      theaterChaseRainbow(50);
      return;
    }

    // set PWM for each led
    analogWrite(led1, r);
    analogWrite(led2, g);
    analogWrite(led3, b);

    for (i = strip.numPixels() - 1; i >= 0; i--) {
      strip.setPixelColor(i, strip.Color(r, g, b));
      strip.show();
    }
  }
}

int debounce(int state)
{
  digitalWrite(led1, LOW);
  digitalWrite(led2, LOW);
  digitalWrite(led3, LOW);

  int start = millis();
  int debounce_start = start;

  while (millis() - start < debounce_timeout)
    if (digitalRead(button) == state)
    {
      if (millis() - debounce_start >= debounce_time) {
        return 1;
      }
    } else {
      debounce_start = millis();
    }
  analogWrite(led1, 255);
  analogWrite(led2, 255);
  analogWrite(led3, 255);

  return 0;
}

int delay_until_button(int state)
{
  // set button edge to wake up on
  if (state)
    RFduino_pinWake(button, HIGH);
  else
    RFduino_pinWake(button, LOW);

  do
    // switch to lower power mode until a button edge wakes us up
    RFduino_ULPDelay(INFINITE);
  while (! debounce(state));

  // if multiple buttons were configured, this is how you would determine what woke you up
  if (RFduino_pinWoke(button))
  {
    // execute code here
    lightsOn = !lightsOn;
    if (lightsOn == false) {
      allLightsOn(false);
    } else {
      allLightsOn(true);
    }

    RFduino_resetPinWake(button);
  }
}

void rainbow(uint8_t wait) {
  int i, j;

  for (j = 0; j < 384; j++) {   // 3 cycles of all 384 colors in the wheel
    for (i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel( (i + j) % 384));
      analogWrite(led1, Wheel( (i + j) % 384));
      analogWrite(led2, Wheel( (i + j) % 384));
      analogWrite(led3, Wheel( (i + j) % 384));
    }
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

// Slightly different, this one makes the rainbow wheel equally distributed
// along the chain
void rainbowCycle(uint8_t wait) {
  uint16_t i, j;

  for (j = 0; j < 384 * 5; j++) {   // 5 cycles of all 384 colors in the wheel
    for (i = 0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 384-color wheel
      // (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
      strip.setPixelColor(i, Wheel( ((i * 384 / strip.numPixels()) + j) % 384) );
    }
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

// Fill the dots progressively along the strip.
void colorWipe(uint32_t c, uint8_t wait) {
  int i;

  for (i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, c);
    strip.show();
    delay(wait);
  }
}

// Chase one dot down the full strip.
void colorChase(uint32_t c, uint8_t wait) {
  int i;

  // Start by turning all pixels off:
  for (i = 0; i < strip.numPixels(); i++) strip.setPixelColor(i, 0);

  // Then display one pixel at a time:
  for (i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, c); // Set new pixel 'on'
    strip.show();              // Refresh LED states
    strip.setPixelColor(i, 0); // Erase pixel, but don't refresh!
    delay(wait);
  }

  strip.show(); // Refresh to turn off last pixel
}

//Theatre-style crawling lights.
void theaterChase(uint32_t c, uint8_t wait) {
  for (int j = 0; j < 10; j++) { //do 10 cycles of chasing
    for (int q = 0; q < 3; q++) {
      for (int i = 0; i < strip.numPixels(); i = i + 3) {
        strip.setPixelColor(i + q, c);  //turn every third pixel on
      }
      strip.show();

      delay(wait);

      for (int i = 0; i < strip.numPixels(); i = i + 3) {
        strip.setPixelColor(i + q, 0);      //turn every third pixel off
      }
    }
  }
}

//Theatre-style crawling lights with rainbow effect
void theaterChaseRainbow(uint8_t wait) {
  for (int j = 0; j < 384; j++) {   // cycle all 384 colors in the wheel
    for (int q = 0; q < 3; q++) {
      for (int i = 0; i < strip.numPixels(); i = i + 3) {
        strip.setPixelColor(i + q, Wheel( (i + j) % 384)); //turn every third pixel on
      }
      strip.show();

      delay(wait);

      for (int i = 0; i < strip.numPixels(); i = i + 3) {
        strip.setPixelColor(i + q, 0);      //turn every third pixel off
      }
    }
  }
}
/* Helper functions */

//Input a value 0 to 384 to get a color value.
//The colours are a transition r - g -b - back to r

uint32_t Wheel(uint16_t WheelPos)
{
  byte r, g, b;
  switch (WheelPos / 128)
  {
    case 0:
      r = 127 - WheelPos % 128;   //Red down
      g = WheelPos % 128;      // Green up
      b = 0;                  //blue off
      break;
    case 1:
      g = 127 - WheelPos % 128;  //green down
      b = WheelPos % 128;      //blue up
      r = 0;                  //red off
      break;
    case 2:
      b = 127 - WheelPos % 128;  //blue down
      r = WheelPos % 128;      //red up
      g = 0;                  //green off
      break;
  }
  return (strip.Color(r, g, b));
}

