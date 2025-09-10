(
// Boot server
s.waitForBoot({

    // --- Shared stereo bus for all sources ---
    ~breathBus = Bus.audio(s, 2);

    // --- Load buffer for granular synth ---
    b = Buffer.readChannel(s, "/Users/stefanopolimeno/Desktop/cpac.wav", channels: [0]);

    // --- inhale synth ---
    SynthDef(\breathe_in, {
        | out=0, gate=1, inFrac1=0.2, inFrac2=0.5, inFrac3=0.3, ampDb=(-12) |
        var env = EnvGen.kr(
            Env.new([0,1,1,0], [inFrac1, inFrac2, inFrac3], curve:'lin'),
            gate,
            doneAction:Done.freeSelf
        );
        var noise = WhiteNoise.ar(ampDb.dbamp);
        var f1 = BPF.ar(noise, 5790, 0.1, -29.dbamp);
        var f2 = BPF.ar(noise, 3400, 0.2, -16.dbamp);
        var f3 = BPF.ar(noise, 1990, 0.1, -23.dbamp);
        var f4 = BPF.ar(noise, 1250, 0.1, -26.dbamp);
        Out.ar(out, env * (f1+f2+f3+f4)!2);
    }).add;

    // --- exhale synth ---
    SynthDef(\breathe_out, {
        | out=0, gate=1, outFrac1=0.4, outFrac2=0.6, ampDb=(-4.33) |
        var env = EnvGen.kr(
            Env.new([0,1,0], [outFrac1, outFrac2], curve:'lin'),
            gate,
            doneAction:Done.freeSelf
        );
        var noise = WhiteNoise.ar(ampDb.dbamp);
        var f1 = BPF.ar(noise, 2290, 0.1, -17.dbamp);
        var f2 = BPF.ar(noise, 1290, 0.1, -19.dbamp);
        var f3 = BPF.ar(noise,  490, 0.1, -18.dbamp);
        Out.ar(out, env * (f1+f2+f3)!2);
    }).add;

    // --- Final FX: FreeVerb + Autopan ---
    SynthDef(\breathFX, { |in=0, out=0, mix=0.5, room=1.0, damp=0.5, panRate=0.1|
        var sig, pan;
        sig = In.ar(in, 2);
        sig = FreeVerb.ar(sig, mix: mix, room: room, damp: damp);
        pan = SinOsc.kr(panRate).range(-0.5, 0.5);
        sig = Balance2.ar(sig[0], sig[1], pan);
        Out.ar(out, sig);
    }).add;

	// buffer for random granular synth (mono)
    b = Buffer.readChannel(s, "/Users/stefanopolimeno/Desktop/cpac.wav", channels: [0]);
    // --- Granular synth ---
    SynthDef(\granularSynth, {
		|out=0, position=0.5, density=10, grainSize=0.1|
		var signal, triggerRate, playbackPosition, randomOffset, randomPan, grains, wetSignal;

		playbackPosition = position * BufSamples.ir(b);
		randomOffset = TRand.ar(-0.05, 0.05, Impulse.ar(density));
		playbackPosition = (playbackPosition + (randomOffset * BufSamples.ir(b))).clip(0, BufSamples.ir(b)-1);
		randomPan = TRand.ar(-1, 1, Impulse.ar(density));
		triggerRate = Impulse.ar(density);

		grains = GrainBuf.ar(
			1,                       // num channels
			triggerRate,             // trigger
			grainSize,               // duration
			b,                       // sound buffer
			1,                       // rate
			playbackPosition / BufSamples.ir(b),  // pos
			5,                       // interp
			0,                       // pan (we’ll pan later)

		);

		signal = Pan2.ar(grains, randomPan);
		wetSignal = 5*FreeVerb.ar(signal, mix: 0.4, room: 1, damp: 0.4);

		Out.ar(out, wetSignal * 0.3);
	}).add;


    s.sync;

    // --- Breathing routine ---
    ~breathRoutine = nil;

    ~makeBreath = { |freq=0.2, out=20|
        var period, inhaleDur, exhaleDur, ampDb, ampDb2;

        if (~breathRoutine.notNil) { ~breathRoutine.stop; };

        ~breathRoutine = Routine({
            inf.do({
                period = 1/freq;
                inhaleDur = 0.45*period;
                exhaleDur = 0.55*period;

                ampDb = (-33).rrand(-14.0);
                ampDb2 = ampDb/2.5;

                Synth(\breathe_in, [
                    \inFrac1, 0.2*inhaleDur,
                    \inFrac2, 0.5*inhaleDur,
                    \inFrac3, 0.3*inhaleDur,
                    \ampDb, ampDb,
                    \out, out
                ]);
                inhaleDur.wait;

                Synth(\breathe_out, [
                    \outFrac1, 0.4*exhaleDur,
                    \outFrac2, 0.6*exhaleDur,
                    \ampDb, ampDb2,
                    \out, out
                ]);
                exhaleDur.wait;
            });
        }).play(SystemClock);
    };

    // --- Start FX on private bus ---
    ~breathFX = Synth(\breathFX, [\in, 20, \out, 0]);

    // --- Start initial breathing ---
    ~breath = ~makeBreath.(0.8, 20);



    x = Synth(\granularSynth, [
        \out, 20,
        \position, 0.1,
        \density, 1,
        \grainSize, 0.8,
    ]);



    // --- OSC listener for granular position, also updates breathing rate ---
	OSCdef(\granularSynthPos, { |msg|
		var value;
		value = msg[1];
		("📩 received /granularSynth/position: " ++ value).postln;

		// Update granular synth position
		x.set(\position, value);

		// Map OSC value (0–1) to breathing frequency (0.1–1 Hz)
		~newFreq = value.linlin(0, 1, 0.2, 0.8); // no "var"
		~makeBreath.(~newFreq, 20);
	}, '/granularSynth/position');
});


)

s.plotTree
