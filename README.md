# Tune

A minimal instrument tuner for iOS and iPadOS.

Listens to your microphone and displays the detected pitch as a note name, frequency, and cents deviation in real time. An analog-style arc gauge gives instant visual feedback — green when in tune, yellow when slightly off, red when significantly off.

**Features:**
- Note name display with octave (e.g., A4, C#5)
- Cents gauge (−50 to +50¢) with color-coded needle
- Configurable A4 reference pitch (420–450 Hz, default 440 Hz)
- Accidentals: sharps, flats, or both

## Requirements

- iOS / iPadOS 26.2+
- Xcode with Swift 5.0

## Dependencies

- [AudioKit](https://github.com/AudioKit/AudioKit)
- [SoundpipeAudioKit](https://github.com/AudioKit/SoundpipeAudioKit)

## License

MIT — see [LICENSE](LICENSE)
