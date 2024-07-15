import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pythonLocation;
float currentFreq = 110; // Initial frequency
color bgColor;

void setup() {
  size(400, 400);
  colorMode(HSB, 360, 100, 100); // Set color mode to HSB
  
  // Start listening for OSC messages on port 12000
  oscP5 = new OscP5(this, 12000);
  
  // Set the destination for OSC messages (Python script)
  pythonLocation = new NetAddress("127.0.0.1", 5000);
  
  updateBackgroundColor();
}

void draw() {
  background(bgColor); // Set the background color based on the received frequency
  
  // Draw a visual representation of the mix and numharm values
  stroke(0, 0, 100); // White stroke
  line(mouseX, 0, mouseX, height);
  line(0, mouseY, width, mouseY);
  
  // Display current frequency
  fill(0, 0, 100); // White text
  textAlign(CENTER, BOTTOM);
  textSize(20);
  text("Frequency: " + nf(currentFreq, 0, 2) + " Hz", width/2, height - 20);
}

// This function is called when an OSC message is received
void oscEvent(OscMessage message) {
  if (message.checkAddrPattern("/from_supercollider")) {
    // Handle message from SuperCollider (frequency value)
    currentFreq = message.get(0).floatValue();
    println("Received frequency from SuperCollider: " + currentFreq);
    
    updateBackgroundColor();
  }
}

void updateBackgroundColor() {
  // Map the frequency to hue (0-360)
  // Using a logarithmic scale for better visual representation
  float hue = map(log(currentFreq), log(20), log(20000), 0, 360);
  hue = (hue + 180) % 360; // Shift hue by 180 degrees for a different color start
  
  // Set saturation and brightness to fixed values for vibrant colors
  float saturation = 80;
  float brightness = 90;
  
  bgColor = color(hue, saturation, brightness);
}

// Function to send OSC message to Python (which will forward to SuperCollider)
void sendToSupercollider(float x, float y) {
  float normalizedX = x / width;
  float normalizedY = 1 - (y / height); // Invert Y so higher values are at the top
  
  OscMessage oscMessage = new OscMessage("/from_processing");
  oscMessage.add(normalizedX);
  oscMessage.add(normalizedY);
  oscP5.send(oscMessage, pythonLocation);
}

// Send a message when mouse is moved
void mouseMoved() {
  sendToSupercollider(mouseX, mouseY);
}
