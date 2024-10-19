import 'dart:async';
import 'dart:io';

import 'package:audio_player/services/audio_service.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
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
  final PlayerController playerController; // Controller to manage the audio player

  /// Subscription for player state changes.
  late StreamSubscription _playerStateSubscription;

  /// Subscription for current duration changes.
  late StreamSubscription _currentDurationSubscription;

  /// Subscription for waveform data updates.
  late StreamSubscription _waveformDataSubscription;

  /// Creates an instance of [AudioPlayerBloc].
  ///
  /// [audioService] is used for audio-related functionalities,
  /// [playerController] is the controller that manages the audio player state.
  AudioPlayerBloc({
    required this.audioService,
    required this.playerController,
  }) : super(const AudioPlayerState()) {
    // Event handlers
    on<InitializePlayer>(_onInitializePlayer);
    on<PlayPauseAudio>(_onPlayPauseAudio);
    on<UpdatePlayingProgress>(_onUpdatePlayingProgress);
    on<UpdateWaveformData>(_onUpdateWaveformData);
    on<SetPlayingCompleted>(_onSetPlayingCompleted);
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
      await _preparePlayer(file); // Prepare the player with the downloaded file
      emit(state.copyWith(status: AudioPlayerStatus.paused)); // Set initial state to paused
    } catch (e) {
      // Emit error message if initialization fails
      emit(state.copyWith(errorMessage: 'Failed to initialize player: $e'));
    }
  }

  /// Prepares the audio player with the downloaded file.
  ///
  /// Sets up listeners for player state changes, current duration,
  /// and waveform data extraction.
  Future<void> _preparePlayer(File file) async {
    // Listen for changes in player state
    _playerStateSubscription = playerController.onPlayerStateChanged.listen((event) async {
      if (event == PlayerState.paused) {
        // Check if the playback has completed
        int duration = await playerController.getDuration(DurationType.current);
        if (duration == 0) {
          add(SetPlayingCompleted()); // Emit completed event
        }
      }
    });

    // Listen for current duration changes and update progress
    _currentDurationSubscription = playerController.onCurrentDurationChanged.listen((duration) {
      add(UpdatePlayingProgress((duration / playerController.maxDuration)));
    });

    // Listen for waveform data updates
    _waveformDataSubscription = playerController.onCurrentExtractedWaveformData.listen((waveData) {
      add(UpdateWaveformData(waveData));
    });

    // Prepare the player with the audio file
    await playerController.preparePlayer(
      path: file.path,
      shouldExtractWaveform: true,
      noOfSamples: 58, // Number of waveform samples
    );
  }

  /// Toggles the audio playback state between play and pause.
  void _onPlayPauseAudio(PlayPauseAudio event, Emitter<AudioPlayerState> emit) {
    if (playerController.playerState == PlayerState.playing) {
      playerController.pausePlayer(); // Pause the player
      emit(state.copyWith(status: AudioPlayerStatus.paused)); // Update state to paused
    } else {
      playerController.startPlayer(finishMode: FinishMode.pause); // Start playing audio
      emit(state.copyWith(status: AudioPlayerStatus.playing)); // Update state to playing
    }
  }

  /// Updates the current playing progress in the state.
  void _onUpdatePlayingProgress(UpdatePlayingProgress event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(playingProgress: event.progress)); // Update progress
  }

  /// Updates the waveform data in the state.
  void _onUpdateWaveformData(UpdateWaveformData event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(waveData: event.waveData)); // Update waveform data
  }

  /// Handles the event when playback is completed.
  void _onSetPlayingCompleted(SetPlayingCompleted event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(status: AudioPlayerStatus.paused, playingProgress: 0.0)); // Reset state to paused
  }

  @override
  Future<void> close() {
    _playerStateSubscription.cancel(); // Cancel player state subscription
    _currentDurationSubscription.cancel(); // Cancel current duration subscription
    _waveformDataSubscription.cancel(); // Cancel waveform data subscription
    playerController.dispose(); // Dispose of player controller resources
    return super.close(); // Call the superclass close method
  }
}
