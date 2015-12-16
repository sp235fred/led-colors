import processing.serial.*;

Serial sensor;

PImage slider;
PImage knob;

int numSlider = 3;
int[] slider_x = new int[numSlider];
int[] slider_y = new int[numSlider];
int[] knob_x = new int[numSlider];
int[] knob_y = new int[numSlider];
int count = 0;
int margin = 24;
int ledcolor = 0;
boolean redrecieved = false;
boolean bluerecieved = false;
boolean greenrecieved = false;
int min_x = 19;
int max_x = 200;
int slice = (max_x - min_x) / 8 + 1;
int value = 87;
int new_x;
int knobX0 = min_x;
int knobX1 = min_x;
int knobX2 = min_x;

byte[] rs = { '1', '2', '3', '4', '5', '6', '7', '8' };
byte[] gs = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' };
byte[] bs = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H' };

void setup() {
  size(256, 216);
  slider = loadImage("slider.png");
  knob = loadImage("knob.png");
  for (int i = 0; i < numSlider; i++) {
    slider_x[i] = width / 2 - slider.width / 2;
    slider_y[i] = i * slider.height + margin;
    knob_x[i] = min_x;
    knob_y[i] = slider_y[i];
  }
  sensor = new Serial(this, Serial.list()[1], 9600);
  frameRate(30);
}

void draw() {
  background(240);
  for (int i = 0; i < numSlider; i++) {
    image(slider, slider_x[i], slider_y[i]);
    image(knob, knob_x[i], knob_y[i]);
  }
}

void mouseDragged() {
  for (int i = 0; i < numSlider; i++) {
  if (mouseInRect(knob_x[i], knob_y[i])) {
      new_x = knob_x[i] + mouseX - pmouseX;
      if (new_x > max_x) {
        knob_x[i] = max_x;
      } else {
        if (new_x < min_x) {
          new_x = min_x;
        } else {
          knob_x[i] = new_x;
        }
      }
      int index = (knob_x[i] - min_x) / slice;
      switch (i) {
        case 0:
          sensor.write(rs[index]);
          break;
        case 1:
          sensor.write(gs[index]);
          break;
        case 2:
          sensor.write(bs[index]);
          break;
      }
    }
  }
}
int funcMapValueForSwitch ( int numLocal ) {
 if (numLocal>=49 && numLocal <= 56) return 0;
 if (numLocal>=97 && numLocal <= 104) return 1;
 if (numLocal>=65 && numLocal <= 72) return 2;
 return -1;
}
void serialEvent(Serial s) {
  value = s.read();
  switch (value) {
    case 87: //W
      knobX0 = knob_x[0];
      knobX1 = knob_x[1];
      knobX2 = knob_x[2];
      break;
    case 82: //R
      knob_x[0] = knobX0;
      knob_x[1] = knobX1;
      knob_x[2] = knobX2;
      break;
  }
  ledcolor = funcMapValueForSwitch(value);
  println(value);
  switch (ledcolor) {
    case 0:
      if(!redrecieved){
        if(value==49){
          knob_x[0] = 0*slice+min_x;
        } else if(value == 50) {
          knob_x[0] = 1*slice+min_x;
        } else if(value == 51) {
          knob_x[0] = 2*slice+min_x;
        } else if(value == 52) {
          knob_x[0] = 3*slice+min_x;
        } else if(value == 53) {
          knob_x[0] = 4*slice+min_x;
        } else if(value == 54) {
          knob_x[0] = 5*slice+min_x;
        } else if(value == 55) {
          knob_x[0] = 6*slice+min_x;
        } else if(value == 56) {
          knob_x[0] = 7*slice+min_x;
        }
        redrecieved=true;
        count++;
      }
      break;
    case 1:
      if(!greenrecieved){
        if(value==97){
          knob_x[1] = 0*slice+min_x;
        } else if(value == 98) {
          knob_x[1] = 1*slice+min_x;
        } else if(value == 99) {
          knob_x[1] = 2*slice+min_x;
        } else if(value == 100) {
          knob_x[1] = 3*slice+min_x;
        } else if(value == 101) {
          knob_x[1] = 4*slice+min_x;
        } else if(value == 102) {
          knob_x[1] = 5*slice+min_x;
        } else if(value == 103) {
          knob_x[1] = 6*slice+min_x;
        } else if(value == 104) {
          knob_x[1] = 7*slice+min_x;
        }
        greenrecieved=true;
        count++;
      }
      break;
    case 2:
      if(!bluerecieved){
        if(value==65){
          knob_x[2] = 0*slice+min_x;
        } else if(value == 66) {
          knob_x[2] = 1*slice+min_x;
        } else if(value == 67) {
          knob_x[2] = 2*slice+min_x;
        } else if(value == 68) {
          knob_x[2] = 3*slice+min_x;
        } else if(value == 69) {
          knob_x[2] = 4*slice+min_x;
        } else if(value == 70) {
          knob_x[2] = 5*slice+min_x;
        } else if(value == 71) {
          knob_x[2] = 6*slice+min_x;
        } else if(value == 72) {
          knob_x[2] = 7*slice+min_x;
        }
        bluerecieved=true;
        count++;
      }
      break;
  }
  println(count);
  if(count>=3){
    sensor.write('!');
    count=-1;
  }
}
boolean mouseInRect(int x, int y) {
  return mouseX >= x && mouseX <= x + knob.width && mouseY >= y && mouseY <= y + knob.height;
}
