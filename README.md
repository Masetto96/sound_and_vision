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
For now super collider has a lame gui where you can type some text and it arrives to processing. On the other side, the mouse clicks from processing will be received from supercollider. 

Everything seems to work. We are ready to make some sound and vision with it.

### Note
- `orchestrator.py`has implemented a queing system whereas there are no ques in `orch_no_que.py`. 
- Shall the mapping happen in python? It's easier but I guess not faster.

## TODOs
- make some sounds
- draw some visuals
- most importantly, define the *mapping of the parameters*
- improve servers handling and this software dev stuff
- *already* refactor orchestrator

## Known Issues
- multiple servers in super collider causing messages to be received more than once.