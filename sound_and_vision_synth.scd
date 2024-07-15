
// Instrument definition
(
SynthDef.new(\stupid_synth, {
	| freq = 110,
	vol = 1,
	mix = 0.5|

	var sin, harm, sig, out;

	sin = SinOsc.ar(freq*2);
	harm = Blip.ar(freq, numharm: 40);
	sig = SelectX.ar(mix, [sin, harm]) * vol;
	out = Out.ar(0, sig!2);
}).add
);

// OSC addresses for sending and receiving (here they are the same, modify accordingly!)
(
~receiving_addr = NetAddr("127.0.0.1", 57120);
~sending_addr = NetAddr.new("127.0.0.1", 57120)
);


// OSC listener
(
OSCdef('stupid_OSC', {
	arg msg;
	msg.postln;

	~stupidsynth.set(
		\mix, msg[1]);
}, "/Python_to_SC" )
);

// Instantiate a synthesizer
~stupidsynth = Synth.new(\stupid_synth, [\vol, 0.3]);

// Change the timbre with the via OSC messages
~sending_addr.sendMsg("/Python_to_SC", 0.1); // --> change the value here!