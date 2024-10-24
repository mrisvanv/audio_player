import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_player/method_channels/audio_codec/audio_codec.dart';
import 'package:audio_player/services/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'audio_player_event.dart';
import 'audio_player_state.dart';

/// Bloc that manages the audio player state and actions.
///
/// This class handles events related to audio playback, such as
/// initializing the player, playing/pausing audio, updating
/// the playing progress, and managing waveform data.
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioService audioService; // Service responsible for audio operations
  final AudioCodec audioCodec; // Controller to manage the audio player

  /// Subscription for player state changes.
  // late StreamSubscription _playerStateSubscription;

  /// Subscription for current duration changes.
  late StreamSubscription _currentDurationSubscription;

  /// Subscription for waveform data updates.
  late StreamSubscription<List<double>> _waveformDataSubscription;

  /// subscription for playerEnded
  late StreamSubscription _playerEndedSubscription;

  /// Creates an instance of [AudioPlayerBloc].
  ///
  /// [audioService] is used for audio-related functionalities,
  /// [audioCodec] is the controller that manages the audio player state.
  AudioPlayerBloc({
    required this.audioService,
    required this.audioCodec,
  }) : super(const AudioPlayerState()) {
    // Event handlers
    on<InitializePlayer>(_onInitializePlayer);
    on<PlayPauseAudio>(_onPlayPauseAudio);
    on<UpdatePlayingProgress>(_onUpdatePlayingProgress);
    on<UpdateWaveformData>(_onUpdateWaveformData);
    on<SetPlayingCompleted>(_onSetPlayingCompleted);
    on<SeekAudio>(_onSeekAudio);
  }

  /// Initializes the audio player and handles audio downloading.
  ///
  /// Emits a loading state and updates the state with the download progress
  /// while downloading the audio file.
  Future<void> _onInitializePlayer(
    InitializePlayer event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(state.copyWith(status: AudioPlayerStatus.loading)); // Set loading status

    try {
      // Download audio and update progress
      final file = await audioService.downloadAudio(
        (progress) => emit(state.copyWith(downloadProgress: progress)),
      );

      // Prepare the player with the downloaded file and extract waveform data
      _preparePlayer(file);
    } catch (e) {
      // Emit error message if initialization fails
      emit(state.copyWith(errorMessage: 'Failed to initialize player: $e'));
    }
  }

  /// Prepares the audio player with the downloaded file.
  ///
  /// Sets up listeners for waveform data extraction.
  Future<void> _preparePlayer(File file) async {
    // Listen for changes in player state
    // _playerStateSubscription = playerController.onPlayerStateChanged.listen((event) async {
    //   if (event == PlayerState.paused) {
    //     // Check if the playback has completed
    //     int duration = await playerController.getDuration(DurationType.current);
    //     if (duration == 0) {
    //       add(SetPlayingCompleted()); // Emit completed event
    //     }
    //   }
    // });

    // Listen for current duration changes and update progress
    _currentDurationSubscription = audioCodec.onCurrentDurationChanged.listen((duration) {
      add(UpdatePlayingProgress((duration / (1000 * audioCodec.totalDuration.inSeconds))));
    });

    // Listen for player ended
    _playerEndedSubscription = audioCodec.onPlayerEnded.listen((_) {
      add(SetPlayingCompleted());
    });

    // Listen for waveform data updates
    _waveformDataSubscription = audioCodec.pcmDataStream.listen((waveData) {
      // final reducedWaveData = reduceWaveformPoints(waveData, 1);
      // final normalizedWaveData = normalizeWaveformPoints(reducedWaveData, 0, 50);
      add(UpdateWaveformData(waveData));
    });

    // Process the audio file
    await audioCodec.processAudioFile(file.path);
    // print("Duration of the audio file: ${audioCodec.totalDuration}");
  }

  /// Toggles the audio playback state between play and pause.
  void _onPlayPauseAudio(PlayPauseAudio event, Emitter<AudioPlayerState> emit) {
    if (state.status == AudioPlayerStatus.playing) {
      audioCodec.pausePlayer(); // Pause the player
      emit(state.copyWith(status: AudioPlayerStatus.paused)); // Update state to paused
    } else {
      audioCodec.playPlayer(); // Start playing audio
      emit(state.copyWith(status: AudioPlayerStatus.playing)); // Update state to playing
    }
  }

  /// Updates the current playing progress in the state.
  void _onUpdatePlayingProgress(UpdatePlayingProgress event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(
      playingProgress: min(event.progress, 1),
      currentDuration: Duration(
        milliseconds: (event.progress * audioCodec.totalDuration.inMilliseconds).toInt(),
      ),
    )); // Update progress
  }

  /// Updates the waveform data in the state.
  void _onUpdateWaveformData(UpdateWaveformData event, Emitter<AudioPlayerState> emit) {
    if (state.status == AudioPlayerStatus.loading || state.status == AudioPlayerStatus.initial) {
      emit(state.copyWith(
          waveData: event.waveData,
          totalDuration: audioCodec.totalDuration,
          status: AudioPlayerStatus.paused)); // Update waveform data with initial status
    } else {
      emit(state.copyWith(waveData: event.waveData, totalDuration: audioCodec.totalDuration)); // Update waveform data
    }
  }

  /// Handles the event when playback is completed.
  void _onSetPlayingCompleted(SetPlayingCompleted event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(
        status: AudioPlayerStatus.paused,
        playingProgress: 0.0,
        currentDuration: Duration.zero)); // Reset state to paused
  }

  /// Seeks to a specific position in the audio.
  void _onSeekAudio(SeekAudio event, Emitter<AudioPlayerState> emit) {
    final progress = event.progress;
    final seekDuration = Duration(milliseconds: (progress * audioCodec.totalDuration.inMilliseconds).toInt());
    audioCodec.seekTo(seekDuration);
    emit(state.copyWith(playingProgress: progress, currentDuration: seekDuration));
  }

  @override
  Future<void> close() {
    _currentDurationSubscription.cancel(); // Cancel current duration subscription
    _playerEndedSubscription.cancel(); // Cancel player ended subscription
    _waveformDataSubscription.cancel(); // Cancel waveform data subscription
    audioCodec.dispose(); // Dispose of audio codec resources
    return super.close(); // Call the superclass close method
  }
}