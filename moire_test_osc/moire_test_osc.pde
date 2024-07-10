import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

float angle;
float rotationSpeed;
int num;
float dia;
color patternColor;

void setup() {
  size(963, 1000);
  surface.setLocation(957, 0);
  noStroke();
  
  oscP5 = new OscP5(this, 12000);  // Listen on port 12000
  myRemoteLocation = new NetAddress("127.0.0.1", 5000);  // python's default port
  
  // Initialize variables with default values
  float rotationSpeed = 0.02;
  num = 100;
  dia = 150;
  patternColor = color(0, 15, 30);
}

void draw() {
  background(255);
  float x = width;
  
  fill(patternColor);
  translate(width/2, height/2);
  for (float a=0; a<360; a+=22.5) {
    rotate(radians(a));
    pushMatrix();
    for (int i=0; i<num; i++) {
      scale(0.95);
      rotate(radians(angle));
      ellipse(x, 0, dia, dia);
    }
    popMatrix();
    pushMatrix();
    for (int i=0; i<num; i++) {
      scale(0.95);
      rotate(-radians(angle));
      ellipse(x, 0, dia, dia);
    }
    popMatrix();
  }
  angle = rotationSpeed;
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/moire/rotation")) {
    rotationSpeed = theOscMessage.get(0).floatValue();
    println("Received /rotation: " + rotationSpeed);
  } else if (theOscMessage.checkAddrPattern("moire/density")) {
    num = int(theOscMessage.get(0).floatValue());
    println("Received /density: " + num);
  } else if (theOscMessage.checkAddrPattern("moire/size")) {
    dia = theOscMessage.get(0).floatValue();
    println("Received /size: " + dia);
  } else if (theOscMessage.checkAddrPattern("moire/color")) {
    patternColor = color(
      theOscMessage.get(0).floatValue(),
      theOscMessage.get(1).floatValue(),
      theOscMessage.get(2).floatValue()
    );
    println("Received /color: R=" + theOscMessage.get(0).floatValue() + 
            ", G=" + theOscMessage.get(1).floatValue() + 
            ", B=" + theOscMessage.get(2).floatValue());
  }
}

// Function to send OSC message to Python (which will forward to SuperCollider)
void sendDensityToSupercollider(int message) {
  OscMessage oscMessage = new OscMessage("/moire/density");
  oscMessage.add(message);
  oscP5.send(oscMessage, myRemoteLocation);
}

void keyPressed() {
  if (key == 'u' || key == 'U') {
    num += 10;
    println("Increased num: " + num);
  } else if (key == 'd' || key == 'D') {
    num -= 10;
    println("Decreased num: " + num);
  } else if (key == 'i' || key == 'I') {
    dia += 10;
    println("Increased dia: " + dia);
    sendDensityToSupercollider(+12);
  } else if (key == 'o' || key == 'O') {
    dia -= 10;
    sendDensityToSupercollider(-12);
    println("Decreased dia: " + dia);
  }
}
