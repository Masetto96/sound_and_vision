(
s.quit;
s.boot;
s.waitForBoot({
    // Instrument definition
    SynthDef.new(\osc_controlled_synth, {
        |freq = 110, vol = 1, mix = 0.5, numharm = 40|
        var sin, harm, sig, out;
        sin = SinOsc.ar(freq*2);
        harm = Blip.ar(freq, numharm: numharm);
        sig = SelectX.ar(mix, [sin, harm]) * vol;
        out = Out.ar(0, sig!2);
    }).add;

    // Wait for SynthDef to be added to the server
    s.sync;

    // OSC addresses for sending and receiving
    ~receiving_addr = NetAddr("127.0.0.1", 57120);
    ~sending_addr = NetAddr.new("127.0.0.1", 57120);

    // OSC listener
    OSCdef(\osc_controlled_synth, {
        |msg, time, addr, recvPort|
        var x = msg[1].linlin(0, 1, 0, 1);  // Assuming x is normalized between 0 and 1
        var y = msg[2].linlin(0, 1, 1, 100);  // Assuming y is normalized between 0 and 1

        "Received x: %, y: %".format(x, y).postln;

        ~controlledSynth.set(
            \mix, x,
            \numharm, y
        );
    }, "/from_processing");

    // Instantiate a synthesizer
    ~controlledSynth = Synth.new(\osc_controlled_synth, [\vol, 0.3]);

    "Synth created and OSC listener set up.".postln;
});
)

// Example: how to send test messages (you won't need this in your actual setup)
// ~sending_addr.sendMsg("/Python_to_SC", 0.5, 0.5);  // x = 0.5, y = 0.5