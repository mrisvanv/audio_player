import 'package:audio_player/blocs/audio_player/audio_player_bloc.dart';
import 'package:audio_player/blocs/audio_player/audio_player_event.dart';
import 'package:audio_player/blocs/audio_player/audio_player_state.dart';
import 'package:audio_player/widgets/visualizer/visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A StatelessWidget that serves as the main home page for the audio player application.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.55, -0.45),
          end: Alignment(0.9, 0.25),
          colors: [
            Color(0xFF7d56ff),
            Color(0xFF11a5ff),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make the background transparent
        appBar: AppBar(
          title: const Text('Audio Player'),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.transparent,
          // Transparent app bar
          elevation: 0,
          // No shadow
          centerTitle: true, // Center the title
        ),
        body: Center(
          child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 4),
                  // Visualizer widget to show audio waveform
                  Visualizer(
                    waveData: state.waveData,
                    currentStatus: _mapStatusToVisualizerStatus(state),
                    progress: state.playingProgress,
                    onPlayPause: () => context.read<AudioPlayerBloc>().add(PlayPauseAudio()),
                    loadingProgress: state.downloadProgress,
                  ),
                  const Spacer(flex: 3),
                  // Display error message if any
                  Visibility(
                    visible: state.errorMessage.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5), // Semi-transparent background
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            state.errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red, // Red text for error message
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Maps the current [AudioPlayerState] to the corresponding [VisualizerStatus].
  ///
  /// This method translates the audio player's status to a visualizer status
  /// used for updating the visual representation of audio playback.
  VisualizerStatus _mapStatusToVisualizerStatus(AudioPlayerState state) {
    switch (state.status) {
      case AudioPlayerStatus.playing:
        return VisualizerStatus.playing; // Playing status
      case AudioPlayerStatus.paused:
        return VisualizerStatus.paused; // Paused status
      default:
        return VisualizerStatus.downloading; // Default to downloading status
    }
  }
}
