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
   
   You could use command-line arguments to customize IP addresses and ports but use default ones!
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

# Human Generated Text
## Recap

Some basic stuff:

- on the super collider side midi notes are played in a sequence and the velocity, which is randomized, is mapped onto the rotation speed of the visuals.
- on processing side there is the implementation of the optical illusion kinda thing inspired by moire patterns. The keys "i" adn "u" can be pressed to increase the density of the pattern and they will produce an octave shift in the supercollider notes.

