import 'dart:math';
import 'dart:typed_data';

/// Procedural 8-bit Square Wave Sound Generator for Authentic Nokia 1100 Monophonic Audio.
/// Generates uncompressed mono WAV bytes directly in memory, ensuring zero network latency
/// and exact reproduction of the Nokia 1100 piezo buzzer.
class SoundGenerator {
  static const int sampleRate = 22050;

  /// Helper to wrap raw 8-bit unsigned PCM samples into a valid WAV file.
  static Uint8List createWav(List<int> samples) {
    final int dataSize = samples.length;
    final int fileSize = 36 + dataSize;
    final ByteData header = ByteData(44);

    // "RIFF"
    header.setUint8(0, 0x52);
    header.setUint8(1, 0x49);
    header.setUint8(2, 0x46);
    header.setUint8(3, 0x46);
    header.setUint32(4, fileSize, Endian.little);
    // "WAVE"
    header.setUint8(8, 0x57);
    header.setUint8(9, 0x41);
    header.setUint8(10, 0x56);
    header.setUint8(11, 0x45);
    // "fmt "
    header.setUint8(12, 0x66);
    header.setUint8(13, 0x6D);
    header.setUint8(14, 0x74);
    header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little); // Subchunk1Size
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // Mono
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate, Endian.little); // ByteRate (1 channel * 8 bit)
    header.setUint16(32, 1, Endian.little); // BlockAlign
    header.setUint16(34, 8, Endian.little); // 8-bit samples
    // "data"
    header.setUint8(36, 0x64);
    header.setUint8(37, 0x61);
    header.setUint8(38, 0x74);
    header.setUint8(39, 0x61);
    header.setUint32(40, dataSize, Endian.little);

    final Uint8List wavBytes = Uint8List(44 + dataSize);
    wavBytes.setRange(0, 44, header.buffer.asUint8List());
    wavBytes.setRange(44, 44 + dataSize, samples);
    return wavBytes;
  }

  /// Generates a square wave tone with optional envelope decay.
  static List<int> _generateSquareTone({
    required double frequency,
    required double durationSeconds,
    double volume = 0.6,
  }) {
    final int totalSamples = (sampleRate * durationSeconds).round();
    final List<int> samples = List<int>.filled(totalSamples, 128);
    final double periodSamples = sampleRate / frequency;

    final int highVal = (128 + (127 * volume)).clamp(0, 255).round();
    final int lowVal = (128 - (127 * volume)).clamp(0, 255).round();

    for (int i = 0; i < totalSamples; i++) {
      final double phase = (i % periodSamples) / periodSamples;
      // Slight decay toward the end of note to avoid harsh clicks
      final double decay = (totalSamples - i) / totalSamples;
      final int currentHigh = (128 + ((highVal - 128) * decay)).round();
      final int currentLow = (128 - ((128 - lowVal) * decay)).round();
      samples[i] = phase < 0.5 ? currentHigh : currentLow;
    }
    return samples;
  }

  /// Keypad click sound (short sharp tick)
  static Uint8List keyClick() {
    final List<int> samples = _generateSquareTone(
      frequency: 1800,
      durationSeconds: 0.015,
      volume: 0.4,
    );
    return createWav(samples);
  }

  /// Food eaten sound (iconic high-pitch blip)
  static Uint8List eatFood() {
    final List<int> samples = _generateSquareTone(
      frequency: 1760, // A6 note
      durationSeconds: 0.045,
      volume: 0.65,
    );
    return createWav(samples);
  }

  /// Bonus food appears (brief two-tone alert)
  static Uint8List bonusSpawn() {
    final List<int> s1 = _generateSquareTone(
      frequency: 880,
      durationSeconds: 0.04,
      volume: 0.6,
    );
    final List<int> s2 = _generateSquareTone(
      frequency: 1320,
      durationSeconds: 0.05,
      volume: 0.6,
    );
    return createWav([...s1, ...s2]);
  }

  /// Bonus food eaten (cheerful 3-tone rising fanfare)
  static Uint8List eatBonus() {
    final List<int> s1 = _generateSquareTone(
      frequency: 1174.66, // D6
      durationSeconds: 0.035,
      volume: 0.7,
    );
    final List<int> s2 = _generateSquareTone(
      frequency: 1479.98, // F#6
      durationSeconds: 0.035,
      volume: 0.7,
    );
    final List<int> s3 = _generateSquareTone(
      frequency: 1760.00, // A6
      durationSeconds: 0.07,
      volume: 0.7,
    );
    return createWav([...s1, ...s2, ...s3]);
  }

  /// Game over / crash sound (dissonant low buzz buzz)
  static Uint8List crash() {
    final int totalSamples = (sampleRate * 0.35).round();
    final List<int> samples = List<int>.filled(totalSamples, 128);

    double freq = 380;
    for (int i = 0; i < totalSamples; i++) {
      // Frequency slides down harshly
      freq = max(60, 380 - (i / totalSamples * 320));
      final double periodSamples = sampleRate / freq;
      final double phase = (i % periodSamples) / periodSamples;
      // Add a slight noise buzz
      final double noise = (i % 7 == 0) ? 0.3 : 0.0;
      final double decay = (totalSamples - i) / totalSamples;
      final double val = (phase < 0.5 ? 1.0 : -1.0) * (0.8 + noise) * decay;
      samples[i] = (128 + val * 120).clamp(0, 255).round();
    }
    return createWav(samples);
  }

  /// High score celebration / Nokia fanfare
  static Uint8List highScoreFanfare() {
    // E6, D6, F#5, G#5, C#6, B5, D5, E5
    final notes = [
      (1318.51, 0.08), // E6
      (1174.66, 0.08), // D6
      (739.99, 0.12),  // F#5
      (830.61, 0.12),  // G#5
      (1108.73, 0.08), // C#6
      (987.77, 0.08),  // B5
      (587.33, 0.12),  // D5
      (659.25, 0.22),  // E5
    ];

    final List<int> allSamples = [];
    for (final note in notes) {
      allSamples.addAll(_generateSquareTone(
        frequency: note.$1,
        durationSeconds: note.$2,
        volume: 0.65,
      ));
      // Tiny 10ms gap between notes
      allSamples.addAll(List<int>.filled((sampleRate * 0.01).round(), 128));
    }
    return createWav(allSamples);
  }
}
