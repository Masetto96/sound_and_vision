import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pythonLocation;

void setup() {
  size(400, 400);
  
  // Start listening for OSC messages on port 12000
  oscP5 = new OscP5(this, 12000);
  
  // Set the destination for OSC messages (Python script)
  pythonLocation = new NetAddress("127.0.0.1", 5000);
}

void draw() {
  // Your drawing code here
}

// This function is called when an OSC message is received
void oscEvent(OscMessage message) {
  if (message.checkAddrPattern("/from_supercollider")) {
    // Handle message from SuperCollider
    println("Received from SuperCollider: " + message.get(0).stringValue());
  }
}

// Function to send OSC message to Python (which will forward to SuperCollider)
void sendToSupercollider(float x, float y) {
  float normalizedX = x / width;
  float normalizedY = y / height;
  
  OscMessage oscMessage = new OscMessage("/from_processing");
  oscMessage.add(normalizedX);
  oscMessage.add(normalizedY);
  oscP5.send(oscMessage, pythonLocation);
}

// Example: send a message when mouse is clicked
void mousePressed() {
  sendToSupercollider(mouseX, mouseY);
}
