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

### Setting up SuperCollider

1. Open SuperCollider.
2. *osc_synth_with_colors.scd*

### Setting up Processing

1. Open Processing.
2. *colors_and_mouse.pde*

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
- Receives x and y coordinates from the mouse from processing and sends them to supercollider, mapped onto synth params.
The mix parameter is controlled by the x coordinate while the numharm parameter is controlled by the y coordinate.

- The frequency in Hz played by the synth in sc will be sent to processing and it will change the background color.


## Known Issues
- multiple servers in super collider causing messages to be received more than once.