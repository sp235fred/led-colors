import processing.serial.*;

Serial sensor;

PImage slider;
PImage knob;
String lines[] = {str(0), str(0), str(0)};
PrintWriter output = createWriter("nums.txt");
BufferedReader reader = createReader("nums.txt");

int numSlider = 3;
int[] slider_x = new int[numSlider];
int[] slider_y = new int[numSlider];
int[] knob_x = new int[numSlider];
int[] knob_y = new int[numSlider];
int margin = 24;
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
  lines = loadStrings("nums.txt");
  println(lines.length);
  for (int i = 0; i < numSlider; i++) {
    slider_x[i] = width / 2 - slider.width / 2;
    slider_y[i] = i * slider.height + margin;
    knob_x[i] = parseInt(lines[i]);
    knobX0=parseInt(lines[0]);
    knobX1=parseInt(lines[1]);
    knobX2=parseInt(lines[2]);
    knob_y[i] = slider_y[i];
  }
  sensor = new Serial(this, Serial.list()[0], 9600);
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

void serialEvent(Serial s) {
  value = s.read();
  switch (value) {
    case 87: //W
      knobX0 = knob_x[0];
      knobX1 = knob_x[1];
      knobX2 = knob_x[2];
      for (int i = 0 ; i < lines.length; i++) {
         lines[i]=str(knob_x[i]);
      }
      saveStrings("nums.txt", lines);
      break;
    case 82: //R
      knob_x[0] = knobX0;
      knob_x[1] = knobX1;
      knob_x[2] = knobX2;
      //knob_x[0] = b[0];
      //knob_x[1] = b[1];
      //knob_x[2] = b[2];
      break;
  }
}
boolean mouseInRect(int x, int y) {
  return mouseX >= x && mouseX <= x + knob.width && mouseY >= y && mouseY <= y + knob.height;
}
