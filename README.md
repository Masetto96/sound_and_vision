# TBD

This project provides a framework for bidirectional communication between SuperCollider and Processing, using Python as an orchestrator. It uses Open Sound Control (OSC) for message passing between the applications.

## Overview

The system consists of three main components:

1. **Python Orchestrator**: routing messages between SuperCollider and Processing.
2. **SuperCollider**: Handles audio processing and can send/receive OSC messages.
3. **Processing**: Manages visual elements and can send/receive OSC messages.

## Installation
The only requirements are `python-osc` for python, and `oscP5` for processing.

## Usage

### Starting the Python Orchestrator
   ```
   python orchestrator.py
   ```
   
   You can use command-line arguments to customize IP addresses and ports:
   ```
   python orchestrator.py --sc-ip 127.0.0.1 --sc-port 57120 --processing-ip 127.0.0.1 --processing-port 12000 --py-ip 127.0.0.1 --py-port 5000
   ```

### Setting up SuperCollider

1. Open SuperCollider.
2. Copy the code from `supercollider_receiver.scd` into a new SuperCollider document.
3. Execute the code (usually by pressing Ctrl+Enter or Cmd+Enter).

### Setting up Processing

1. Open Processing.
2. Create a new sketch and copy the code from `processing_osc_setup.pde`.
3. Run the sketch.

## Sending Messages

### From Python to SuperCollider or Processing
Use the command-line interface of the Python orchestrator:

```
Enter command (sc/proc/quit): sc
Enter OSC address: /from_processing or /from_supercollider
Enter message: Hello World
```

# Human Generated Text

## Recap
Receives x and y coordinates from the mouse from processing and sends them to supercollider, mapeped onto synth params.
The mix parameter is controlled by the x coordinate, the numharm parameter is controlled by the y coordinate.

The frequency in Hz played by the synth in sc will be sent to processing and it will change the background color.

### Processing *colors_and_mouse.pde*
### SC - *osc_synth_with_colors.scd*

## Known Issues
- multiple servers in super collider causing messages to be received more than once.