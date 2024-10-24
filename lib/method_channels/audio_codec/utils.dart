import 'dart:math';
import 'dart:typed_data';

/// Normalizes the waveform data to a range between 0 and 1.
///
/// The normalization is done by scaling the waveform based on
/// the minimum and maximum values of the data.
///
/// This method ensures that the waveform values fit within a consistent
/// range, which is useful for displaying visualizations of the waveform.
List<double> normalizeWaveform(List<double> waveform) {
  if (waveform.isEmpty) return []; // Handle empty waveform case

  // Find the maximum and minimum values of the waveform
  final double maxValue = waveform.reduce(max);
  final double minValue = waveform.reduce(min);
  final double range = maxValue - minValue;

  // If the range is 0, return the waveform as-is to avoid division by zero.
  return waveform.map((value) => range == 0 ? value : (value - minValue) / range).toList();
}

/// Processes PCM data according to the bit depth (8, 16, or 32 bits) and the number of channels.
///
/// The method determines the correct handler based on the `pcmEncodingBit` and
/// processes the PCM data into floating-point values representing the waveform.
///
/// The returned floating-point values are used to calculate the waveform and
/// display it graphically or further process it (e.g., normalization).
///
/// [pcmData] is the raw PCM data as a `Uint8List`.
/// [channels] indicates if the audio is mono (1) or stereo (2).
/// [pcmEncodingBit] is the bit depth of the PCM data (usually 8, 16, or 32).
double processPcmData(Uint8List pcmData, int channels, int pcmEncodingBit) {
  ByteBuffer buffer = pcmData.buffer; // Buffer holding raw PCM data

  // Choose the handler based on the PCM bit depth
  switch (pcmEncodingBit) {
    case 8:
      return _handle8bit(buffer, channels); // Process 8-bit PCM data
    case 16:
      return _handle16bit(buffer, channels); // Process 16-bit PCM data
    case 32:
      return _handle32bit(buffer, channels); // Process 32-bit PCM data
    default:
      throw UnsupportedError('Unsupported PCM encoding bit depth: $pcmEncodingBit');
  }
}

/// Handles 8-bit PCM data for mono and stereo audio.
///
/// The method converts 8-bit unsigned integers (0 to 255) to floating-point values
/// centered around 0 by subtracting 128 (since 8-bit PCM is unsigned).
///
/// This conversion is needed because audio waveforms typically range from -1 to 1.
///
/// The RMS (Root Mean Square) value is calculated to represent the average amplitude
/// of the waveform, which is returned as a single value.
double _handle8bit(ByteBuffer buffer, int channels) {
  List<double> waveform = [];
  final Uint8List pcmBytes = buffer.asUint8List();

  for (int i = 0; i < pcmBytes.length; i += (channels == 2 ? 2 : 1)) {
    // 8-bit PCM is unsigned, so we subtract 128 to center around 0.
    int sample = pcmBytes[i] - 128;

    if (channels == 2) {
      i++; // Skip the second channel for stereo data.
    }

    waveform.add(sample / 128.0); // Normalize 8-bit PCM values to [-1, 1].
  }

  // Calculate the RMS (Root Mean Square) value for the waveform.
  return _calculateRms(waveform);
}

/// Handles 16-bit PCM data for mono and stereo audio.
///
/// 16-bit PCM is stored as signed integers, so we directly convert
/// the values to the floating-point range [-1, 1] by dividing by 32767 (the max value).
///
/// This method processes each sample, skipping the second channel for stereo audio.
/// The RMS value is calculated for the waveform.
double _handle16bit(ByteBuffer buffer, int channels) {
  List<double> waveform = [];
  final Int16List pcmBytes = buffer.asInt16List();

  for (int i = 0; i < pcmBytes.length; i += (channels == 2 ? 2 : 1)) {
    // 16-bit PCM data is signed, so we divide by 32767.0 to normalize to [-1, 1].
    double sample = pcmBytes[i] / 32767.0;

    if (channels == 2) {
      i++; // Skip the second channel for stereo data.
    }

    waveform.add(sample);
  }

  // Calculate the RMS value for the 16-bit waveform.
  return _calculateRms(waveform);
}

/// Handles 32-bit PCM data for mono and stereo audio.
///
/// 32-bit PCM is stored as signed integers, and we normalize the values to [-1, 1]
/// by dividing by the maximum possible value for a 32-bit signed integer (2147483648.0).
///
/// This method calculates the RMS value for the processed waveform.
double _handle32bit(ByteBuffer buffer, int channels) {
  List<double> waveform = [];
  final Int32List pcmBytes = buffer.asInt32List();

  for (int i = 0; i < pcmBytes.length; i += (channels == 2 ? 2 : 1)) {
    // Normalize 32-bit PCM values to [-1, 1] by dividing by 2147483648.0.
    double sample = pcmBytes[i] / 2147483648.0;

    if (channels == 2) {
      i++; // Skip the second channel for stereo data.
    }

    waveform.add(sample);
  }

  // Return the RMS value for the 32-bit PCM data.
  return _calculateRms(waveform);
}

/// Reduces the waveform points to a specified number of samples using RMS calculation.
///
/// This method breaks the waveform into smaller chunks (sub-waves) and calculates
/// the RMS value for each chunk. It reduces the total number of waveform points
/// to a manageable size for better visualization or processing performance.
///
/// [noOfSamples] defines how many sample points the reduced waveform should have.
List<double> reduceWaveformPoints(List<double> waveform, int noOfSamples) {
  if (waveform.isEmpty) return [];

  final double pointsPerSample = waveform.length / noOfSamples;
  List<double> reducedWaveform = [];

  // Iterate over the waveform and reduce it to the desired number of points
  for (double i = 0; i < waveform.length; i += pointsPerSample) {
    // Get the chunk of data that corresponds to this sample
    int end = ((i + pointsPerSample).round()).clamp(0, waveform.length);
    List<double> chunk = waveform.sublist(i.round(), end);

    // Calculate the RMS value of the chunk and add it to the reduced waveform
    reducedWaveform.add(_calculateRms(chunk));
  }

  return reducedWaveform;
}

/// Calculates the Root Mean Square (RMS) of a given waveform chunk.
///
/// The RMS value represents the "average" power or amplitude of the waveform,
/// which is useful for audio visualization and processing.
double _calculateRms(List<double> waveform) {
  if (waveform.isEmpty) return 0.0; // Handle empty waveform case

  // Sum of squares of the waveform values
  double sumOfSquares = waveform.fold(0, (sum, value) => sum + pow(value, 2));

  // Return the square root of the average of the squares
  return sqrt(sumOfSquares / waveform.length);
}
