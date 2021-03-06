s.reboot;
//if server gets stuck
Server.killAll;

MIDIClient.init; // connnection with OS
MIDIClient.sources; //availables source devices
MIDIIn.connect(0)// para conectar solo uno en el paréntesis el index
MIDIIn.connectAll; //conectarlos todos
MIDIIn.release; // end connection

(
    MIDIIn.noteOff = { arg src, chan, num, vel;
	[chan,num,vel / 127].postln; };

    MIDIIn.noteOn = { arg src, chan, num, vel;
	[chan,num,vel,src / 127].postln; };

    MIDIIn.polytouch = { arg src, chan, num, vel;
	[chan,num,vel / 127].postln; };

	MIDIIn.control = { arg src, chan, num, val;
	[chan,num,val].postln; };

	MIDIIn.program = { arg src, chan, prog;
	[chan,prog].postln; };

	MIDIIn.touch = { arg src, chan, pressure;
	[chan,pressure].postln; };

	MIDIIn.bend = { arg src, chan, bend;
	[chan,bend - 8192].postln; };

	MIDIIn.sysex = { arg src, sysex;
	sysex.postln; };

	MIDIIn.sysrt = { arg src, chan, val;
	[chan,val].postln; };

	MIDIIn.smpte = { arg src, chan, val;
	[chan,val].postln; };
)

// PARA MIDIdefs
//Prueba note On
MIDIdef.noteOn(\Pd, {"recibiendo".postln});
// able or disable
MIDIdef(\Pd).disable;
// free one
MIDIdef(\Pd).free;
//freeAll
MIDIdef.freeAll;




~frecuenciasEEG = Array.newClear(128);

//CHANNEL 2

(
MIDIdef.noteOn(\OnChan2, {
	arg  vel, nn, chan;
	[vel, nn, chan].postln;
	~frecuenciasEEG[nn] = Synth.new(
		\trial2,
		[
			\freq, nn.midicps,
	        \gate, 1,
	]
	);
	}, chan:0);

MIDIdef.noteOff(\OffChan2, {
arg vel, nn, chan;
	[vel, nn, chan].postln;
	~frecuenciasEEG[nn].set(\gate, 0);
	~frecuenciasEEG[nn] = nil;
});

SynthDef.new(\trial2, {
	arg freq=700, amp=0.5, gate=0;
	var sig, env;
		sig = SinOsc.ar(freq)!2;
		env = EnvGen.kr(Env.adsr, gate, doneAction:2);
		sig = sig * env * amp;
	    Out.ar(0, sig);
}).add;
)







///CHANNEL 1 ANTERIOR SOSTENIDO FUNCIONA

(
MIDIdef.noteOn(\chan0, {
	arg vel, nn, chan;
	[vel, nn, chan].postln;
	Synth.new(\esm, [\cutoff, 2000, \fdec, 3, \fint, 1, \od, 0.5, \glide, 0.5]);
	}, chan:0);

SynthDef(\esm, {|freq=440, mix=0.5, glide=0, cutoff=20000, rq=1, fdec=0, fint=1,
	vel=1, fvel=1, t_gate=1, vdec=1, vvel=0, od=0, mul=0.1, pan=0, out=0|
	var sig, saw, rect, fstart, fenv, vstart, venv;

	freq = freq.lag(glide);

	// oscillators
	saw = LFSaw.ar(freq, 0, 1);
	rect = LFPulse.ar(freq, 0, 0.5, 1);
	sig = Mix([saw * (1-mix), rect * mix]);

	// filter
	fstart = vel.linlin(0, fvel, 0, fint).linexp(0, 1, cutoff, 20000);
	fenv = EnvGen.kr(Env([fstart, fstart, cutoff], [0.001, fdec]), t_gate);
	sig = LPF.ar(sig, fenv, rq);

	// volume env
	vstart = vel.linlin(0, vvel.max(10e-1), 0, 1);
	venv = EnvGen.ar(Env([vstart, vstart, 0], [0.01, vdec], \cub), t_gate);
	sig = sig * venv;

	// distortion
	sig = sig * od.linlin(0, 1, 1, 100).clip2(mul);

	Out.ar(out,
		Pan2.ar(sig, pan);
	)
}).play;

)





MIDIClient.stop;

(
var notes, on, off;
MIDIClient.init;

MIDIIn.connectAll;

notes = Array.newClear(128);

on = MIDIFunc.noteOn({|vel, num, chan, src|
	notes[num] = Synth(\default, [\freq, num.midicps, \amp, vel * 0.00315]);
});

off = MIDIFunc.noteOff ({|vel, num, chan, src|
	notes[num].release;
});

q = {on.free; off.free;};
)

Synth.new(\default);

q.value



