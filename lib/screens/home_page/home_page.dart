import 'dart:ui';

import 'package:audio_player/blocs/audio_player/audio_player_bloc.dart';
import 'package:audio_player/blocs/audio_player/audio_player_event.dart';
import 'package:audio_player/blocs/audio_player/audio_player_state.dart';
import 'package:audio_player/utils/extensions.dart';
import 'package:audio_player/widgets/play_pause_control/play_pause_control.dart';
import 'package:audio_player/widgets/wave/wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

/// A StatelessWidget that serves as the main home page for the audio player application.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Align(
            alignment: Alignment.topCenter,
            // padding: const EdgeInsets.only(bottom: 368/2),
            child: Container(
              key: const Key('background_image'),
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height - 368 / 2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.jpg'),
                  // alignment: Alignment.topCenter
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(.15), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent, // Make the background transparent
          body: Center(
            child: BlocListener<AudioPlayerBloc, AudioPlayerState>(
              listener: (context, state) {
                if (state.errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                builder: (context, state) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      key: const Key('audio_player_container'),
                      duration: Duration(milliseconds: 300),
                      width: MediaQuery.sizeOf(context).width,
                      height: [AudioPlayerStatus.initial, AudioPlayerStatus.loading].contains(state.status) ? 230 : 368,
                      decoration: BoxDecoration(
                        color: Color(0xBF313131),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, -5),
                            blurRadius: 15,
                            color: Colors.black.withOpacity(0.25),
                          ),
                        ],
                      ),
                      child: Visibility(
                        visible: ![AudioPlayerStatus.initial, AudioPlayerStatus.loading].contains(state.status),
                        replacement: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Song Title
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade600,
                                  child: Text(
                                    "Loading...",
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 34,
                                      height: 1.12,
                                      // Line Height 38px / Font Size 34px = 1.12
                                      letterSpacing: 0.03 * 34,
                                      // Converting % to logical pixels
                                      color: Color(0xFFEDEDED),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Song Title
                                  _intro(),
                                  _soundWave(context, state),
                                  _controlButton(context, state),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlButton(BuildContext context, AudioPlayerState state) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      width: MediaQuery.sizeOf(context).width,
      child: Center(
        child: PlayPauseControl(
          isPlaying: state.status == AudioPlayerStatus.playing, // boolean state variable
          onTap: () => context.read<AudioPlayerBloc>().add(PlayPauseAudio()),
        ),
      ),
    );
  }

  Widget _soundWave(BuildContext context, AudioPlayerState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 62),
      child: Column(
        children: [
          // AnimatedWaveProgressBar(
          //   waveHeights: state.waveData,
          //   progress: state.playingProgress,
          //   duration: Duration(milliseconds: 30),
          // ),
          WaveProgressBar(
            waveHeights: state.waveData,
            progress: state.playingProgress,
            width: MediaQuery.sizeOf(context).width,
            height: 55,
            plotDuration: Duration(milliseconds: 3000),
            heightDuration: Duration(milliseconds: 1000),
            onSeekProgress: (progress) {
              context.read<AudioPlayerBloc>().add(UpdatePlayingProgress(progress));
            },
            onSeekComplete: (progress) {
              context.read<AudioPlayerBloc>().add(SeekAudio(progress));
              // print('Seek completed at: $progress');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              state.currentDuration.toMSS(),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                height: 0.87,
                // Line Height 14px / Font Size 16px = 0.87
                letterSpacing: 0.03 * 16,
                // Converting em to logical pixels
                color: Color(0xFFEDEDED),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _intro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 36, left: 25),
          child: Text(
            'Instant Crush',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 34,
              height: 1.12,
              // Line Height 38px / Font Size 34px = 1.12
              letterSpacing: 0.03 * 34,
              // Converting % to logical pixels
              color: Color(0xFFEDEDED),
            ),
          ),
        ),

        // Artist Name
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 25),
          child: Text(
            'feat. Julian Casablancas',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.25,
              // Line Height 20px / Font Size 16px = 1.25
              letterSpacing: 0.03 * 16,
              // Converting em to logical pixels
              color: Color(0xFFEDEDED),
            ),
          ),
        ),
      ],
    );
  }
}
