(
// Initialize the server
s.boot;

// Define OSC client and server
~pythonClient = NetAddr("127.0.0.1", 5000);  // Python's default listening port

~octaveShift = 0;  // Global variable to store the octave shift

~oscResponder = OSCFunc({ |msg, time, addr, recvPort|
    var address = msg[0];
    var args = msg[1..];
    "Received from Python: % %".format(address, args).postln;

    // Process incoming messages
    if (address == '/moire/size') {
        ~synth.set(\decay, args[0]);
    };
    if (address == '/moire/density') {
        ~octaveShift = args[0];  // Store the octave shift
        "Octave shift set to %".format(~octaveShift).postln;
    };
}, '/moire/density');

// Function to send messages to Python
~sendToPython = { |address ... args|
    ~pythonClient.sendMsg(address, *args);
    // "Sent to Python: % %".format(address, args).postln;
};

// Define the synth
SynthDef(\simpleSynth, {
    |freq = 440, amp = 0.5, gate = 1, decay = 0.5|
    var env, sig;
    env = EnvGen.kr(Env.asr(0.01, 1, decay), gate, doneAction: 2);
    sig = SinOsc.ar(freq) * env * amp;
    Out.ar(0, sig ! 2);
}).add;

// Sequencer function
~sequencer = {
    var midiLow = 48;  // C3
    var midiHigh = 84; // C6
    var tempo = 60;   // BPM
    var clock = TempoClock(tempo/60);

    clock.sched(0, {
        var midiNote = rrand(midiLow, midiHigh);
        var shiftedNote = midiNote + ~octaveShift;  // Apply octave shift
        var freq = shiftedNote.midicps;
        var vel = rrand(0.3, 1.0);

        // Play the synth
        ~synth = Synth(\simpleSynth, [\freq, freq, \amp, vel]);

        // Send OSC messages
        ~sendToPython.("/moire/rotation", vel);

        1; // Schedule next note in 1 second (quarter notes at 60 BPM)
    });
};

// Start the sequencer
~sequencer.value;

// Cleanup function
CmdPeriod.doOnce({
    ~oscResponder.free;
    "OSC responder freed.".postln;
});
)