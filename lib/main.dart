import 'package:audio_player/blocs/audio_player/audio_player_bloc.dart';
import 'package:audio_player/blocs/audio_player/audio_player_event.dart';
import 'package:audio_player/screens/home_page/home_page.dart';
import 'package:audio_player/services/audio_service.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The main entry point for the Audio Player application.
void main() {
  // Ensure that Flutter widgets binding is initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Run the Audio Player app.
  runApp(const MyApp());
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
          playerController: PlayerController(), // Manages audio playback and waveforms.
        )..add(InitializePlayer()), // Trigger the initialization event for the audio player.

        // The home screen of the app which will be the [HomePage] widget.
        child: const HomePage(),
      ),
    );
  }
}
