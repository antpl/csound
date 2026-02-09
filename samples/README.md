# samp2buffer

A Csound instrument that loads an audio sample into a buffer table and plays it back through an oscillator with harmonic variations and reverb.

## How it works

1. **Instr 1** loads a sample from disk and loops it. Press any key to capture a segment into a buffer table.
2. **Instr 2** writes the current audio into the table.
3. **Instr 3** plays the table back via an oscillator at random harmonic frequencies of 55 Hz, with amplitude variation and stereo panning.
4. **Instr 99** adds reverb to the output.

Each keypress captures a new snippet and triggers a new playback event, allowing layered textures to build up over time.

## Setup

1. Set the `Sdir` and `Sample` variables in **instr 1** to point to your own audio file:
   ```csound
   Sample = "your_sample.wav"
   Sdir = "/path/to/your/samples/"
   ```
2. Run with Csound:
   ```
   csound samp2buffer.csd
   ```

## Requirements

- [Csound](https://csound.com/) (tested with Csound 6)
- An audio file (mono or stereo) to load

## License

MIT License. Free to use. If you use this outside of academic/educational contexts, please let the author know. See [LICENSE](../LICENSE) for details.
