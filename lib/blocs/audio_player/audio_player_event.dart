/// Base class for all audio player events.
///
/// This abstract class serves as the foundation for all events
/// related to audio playback, ensuring a consistent structure
/// for event handling in the audio player.
abstract class AudioPlayerEvent {
  const AudioPlayerEvent();
}

/// Event to initialize the audio player.
///
/// This event triggers the audio player setup process, including
/// downloading the audio file and preparing the player for playback.
class InitializePlayer extends AudioPlayerEvent {}

/// Event to toggle playback between play and pause.
///
/// This event is dispatched when the user interacts with the
/// play/pause control, allowing for audio playback management.
class PlayPauseAudio extends AudioPlayerEvent {}

/// Event to update the current playing progress.
///
/// This event carries the progress value (between 0 and 1) representing
/// the current playback position. It is dispatched whenever there is
/// an update in the playback progress.
class UpdatePlayingProgress extends AudioPlayerEvent {
  final double progress; // Current playback progress as a fraction

  /// Creates an instance of [UpdatePlayingProgress].
  ///
  /// [progress] should be a value between 0.0 and 1.0, indicating
  /// the proportion of the audio that has been played.
  const UpdatePlayingProgress(this.progress);
}

/// Event to update the waveform data.
///
/// This event carries the waveform data used for visualizing
/// the audio playback. The waveform data is typically an array
/// of double values representing the audio signal's amplitude.
class UpdateWaveformData extends AudioPlayerEvent {
  final List<double> waveData; // Waveform data for audio visualization

  /// Creates an instance of [UpdateWaveformData].
  ///
  /// [waveData] is a list of doubles that represent the waveform
  /// of the audio being played.
  const UpdateWaveformData(this.waveData);
}

/// Event to indicate that playback has completed.
///
/// This event is dispatched when the audio playback reaches the
/// end, allowing the system to reset the playback state or
/// perform any necessary cleanup.
class SetPlayingCompleted extends AudioPlayerEvent {}
