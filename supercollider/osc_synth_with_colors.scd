(
s.quit;
s.boot;
s.waitForBoot({
    // Instrument definition
    SynthDef.new(\osc_controlled_synth, {
        |freq = 110, vol = 1, mix = 0.5, numharm = 40|
        var sin, harm, sig, out;
        sin = SinOsc.ar(freq);
        harm = Blip.ar(freq, numharm: numharm);
        sig = SelectX.ar(mix, [sin, harm]) * vol;
        out = Out.ar(0, sig!2);
        SendReply.kr(Impulse.kr(20), '/synth_freq', [freq]); // Send current frequency
    }).add;

    // Wait for SynthDef to be added to the server
    s.sync;

    // OSC addresses for sending and receiving
    ~receiving_addr = NetAddr("127.0.0.1", 57120);
    ~sending_addr = NetAddr.new("127.0.0.1", 5000); // Sending to Python

    // OSC listener
    OSCdef(\osc_controlled_synth, {
        |msg, time, addr, recvPort|
        var x = msg[1].linlin(0, 1, 0, 1);  // x controls mix
        var y = msg[2].linlin(0, 1, 1, 100);  // y controls numharm
        "Received x (mix): %, y (numharm): %".format(x, y).postln;
        ~controlledSynth.set(
            \mix, x,
            \numharm, y
        );
    }, "/from_processing");

    // OSC responder for sending frequency
    OSCdef(\send_freq, {
        |msg|
        var freqValue = msg[3];
        ~sending_addr.sendMsg("/from_supercollider", freqValue);
    }, '/synth_freq');

    // Instantiate a synthesizer
    ~controlledSynth = Synth.new(\osc_controlled_synth, [\vol, 0.3]);
    "Synth created and OSC listener set up.".postln;

    // Function to change frequency manually
    ~changeFreq = {|newFreq|
        ~controlledSynth.set(\freq, newFreq);
        "Frequency changed to %".format(newFreq).postln;
    };

    "Use ~changeFreq.value(newFrequency) to change the frequency manually.".postln;
});
)

/*// Example usage:
~changeFreq.value(5020); // Change frequency to 440 Hz*/