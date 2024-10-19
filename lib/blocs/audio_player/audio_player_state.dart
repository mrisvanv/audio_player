/// Enum representing the various states of the audio player.
enum AudioPlayerStatus {
  /// Initial state, before any audio is loaded or played.
  initial,

  /// State indicating that audio is currently being loaded.
  loading,

  /// State indicating that audio is currently playing.
  playing,

  /// State indicating that audio playback is paused.
  paused,
}

/// Represents the state of the audio player.
///
/// This class encapsulates all relevant information regarding the
/// audio player's status, including its playback progress, download
/// progress, waveform data, and any error messages.
class AudioPlayerState {
  final AudioPlayerStatus status; // Current status of the audio player
  final double playingProgress; // Current playback progress (0.0 to 1.0)
  final double downloadProgress; // Current download progress (0.0 to 1.0)
  final List<double> waveData; // Waveform data for audio visualization
  final String errorMessage; // Any error messages related to audio playback

  /// Creates an instance of [AudioPlayerState].
  ///
  /// The default values for each field are set to ensure
  /// a consistent initial state.
  const AudioPlayerState({
    this.status = AudioPlayerStatus.initial,
    this.playingProgress = 0.0,
    this.downloadProgress = 0.0,
    this.waveData = const [],
    this.errorMessage = '',
  });

  /// Creates a copy of the current state with optional modifications.
  ///
  /// This method allows for the creation of a new [AudioPlayerState]
  /// instance with updated fields while retaining the current values
  /// for any unspecified fields.
  AudioPlayerState copyWith({
    AudioPlayerStatus? status, // New status for the audio player
    double? playingProgress, // New playback progress
    double? downloadProgress, // New download progress
    List<double>? waveData, // New waveform data
    String? errorMessage, // New error message
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      // Use new status or current value
      playingProgress: playingProgress ?? this.playingProgress,
      // Use new progress or current value
      downloadProgress: downloadProgress ?? this.downloadProgress,
      // Use new download progress or current value
      waveData: waveData ?? this.waveData,
      // Use new waveform data or current value
      errorMessage: errorMessage ?? this.errorMessage, // Use new error message or current value
    );
  }
}
