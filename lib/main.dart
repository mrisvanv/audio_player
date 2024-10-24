import 'dart:math' as math;

import 'package:audio_player/blocs/audio_player/audio_player_bloc.dart';
// import 'package:audio_player/blocs/audio_player/audio_player_bloc_.dart';
import 'package:audio_player/blocs/audio_player/audio_player_event.dart';
import 'package:audio_player/method_channels/audio_codec/audio_codec.dart';
import 'package:audio_player/screens/home_page/home_page.dart';
import 'package:audio_player/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The main entry point for the Audio Player application.
Future<void> main() async {
  // Ensure that Flutter widgets binding is initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  // plotAudioWaveform(100);
  // Run the Audio Player app.
  runApp(const MyApp());
}

// void plotAudioWaveform() async {
//   final codec = AudioCodec();
//   final List<double> waveform = [];
//
//   try {
//     // var resultJson;
//     codec.pcmDataStream.listen((data) {
//       List<int> pcmData = data["pcmData"] as Uint8List;
//       int pcmEncodingBit = data["pcmEncodingBit"] as int;
//       // Convert PCM data to waveform points
//       for (int i = 0; i < pcmData.length; i += 2) {
//           if (pcmEncodingBit == 8) {
//             // Assuming 8-bit PCM encoding (1 byte per sample)
//             print("8-bit PCM encoding");
//             final sample = pcmData[i];
//             final normalizedSample = (sample - 128) / 128.0; // Normalize to -1.0 to 1.0
//             waveform.add(normalizedSample);
//             continue;
//           }else if (pcmEncodingBit != 16) {
//             // Assuming 16-bit PCM encoding (2 bytes per sample)
//             print("16-bit PCM encoding");
//             final sample = pcmData[i] | (pcmData[i + 1] << 8);
//             final normalizedSample = sample / 32768.0; // Normalize to -1.0 to 1.0
//             waveform.add(normalizedSample);
//             continue;
//           }else {
//             throw AudioCodecException('Unsupported PCM encoding bit: $pcmEncodingBit');
//           }
//
//       }
//     });
//
//     File file = await AudioService().downloadAudio((progress) {
//       // print('Download progress: $progress');
//     });
//     print('Downloaded audio file: ${file.path}');
//     await codec.processAudioFile(file.path);
//   } catch (e) {
//     print('Error processing audio: $e');
//   } finally {
//     await codec.release();
//     codec.dispose();
//   }
//
//   print('Waveform points: ${waveform.length}');
//   if (waveform.isNotEmpty) {
//     print('First few points: ${waveform.take(5).toList()}');
//     print('Min: ${waveform.reduce((a, b) => a < b ? a : b)}');
//     print('Max: ${waveform.reduce((a, b) => a > b ? a : b)}');
//   }
// }

// void plotAudioWaveform(int noOfSamples) async {
//   final codec = AudioCodec();
//   final List<double> waveform = [];
//
//   try {
//     codec.pcmDataStream.listen((pcmData) {
//       // Convert PCM data to waveform points
//       final bytesPerSample = codec.pcmEncodingBit / 8;
//       for (int i = 0; i < pcmData.length; i += bytesPerSample.toInt()) {
//         final sample =
//             ByteData.sublistView(Uint8List.fromList(pcmData), i, i + bytesPerSample.toInt()).getInt16(0, Endian.little);
//         final normalizedSample = sample / 32768.0; // Normalize to -1.0 to 1.0
//         waveform.add(normalizedSample);
//       }
//     });
//
//     File file = await AudioService().downloadAudio((progress) {
//       // print('Download progress: $progress');
//     });
//     print('Downloaded audio file: ${file.path}');
//     await codec.processAudioFile(file.path);
//
//     final durationInSeconds = codec.durationInSeconds;
//     print('Audio duration: $durationInSeconds seconds');
//   } catch (e) {
//     print('Error processing audio: $e');
//   } finally {
//     await codec.release();
//     codec.dispose();
//   }
//
//   print('Original waveform points: ${waveform.length}');
//   if (waveform.isNotEmpty) {
//     print('First few points: ${waveform.take(5).toList()}');
//     print('Min: ${waveform.reduce((a, b) => a < b ? a : b)}');
//     print('Max: ${waveform.reduce((a, b) => a > b ? a : b)}');
//   }
//
//   // Reduce waveform points to noOfSamples using RMS calculation
//   final reducedWaveform = reduceWaveformPoints(waveform, noOfSamples);
//
//   print('Reduced waveform points: ${reducedWaveform.length}');
//   if (reducedWaveform.isNotEmpty) {
//     print('First few points (reduced): ${reducedWaveform.take(5).toList()}');
//     print('Min (reduced): ${reducedWaveform.reduce((a, b) => a < b ? a : b)}');
//     print('Max (reduced): ${reducedWaveform.reduce((a, b) => a > b ? a : b)}');
//   }
// }

extension DoubleExtensions on double {
  double sqrt() => math.sqrt(this);
}

/// The root widget of the Audio Player application.
///
/// This class is responsible for setting up the [MaterialApp] and injecting
/// dependencies such as the [AudioPlayerBloc] and [AudioService] required for
/// the audio player functionality.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Player',
      theme: ThemeData(
        // Define the theme settings for the app, including color.
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AudioPlayerBloc>(
        // Initialize the AudioPlayerBloc with required dependencies and inject it into the widget tree.
        create: (_) => AudioPlayerBloc(
          audioService: AudioService(), // Provides audio-related functionality.
          // playerController: PlayerController(), // Manages audio playback and waveforms.
          audioCodec: AudioCodec(),
        )..add(InitializePlayer()), // Trigger the initialization event for the audio player.

        // The home screen of the app which will be the [HomePage] widget.
        child: const HomePage(),
      ),
    );
  }
}
