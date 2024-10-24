import 'package:audio_player/method_channels/audio_codec/audio_codec_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of audio_codec must implement.
///
/// Platform implementations should extend this class rather than implement it as `AudioCodecPlatform`
/// does. This will ensure that the platform-adaptive implementation will be used when the package is
/// consumed as a plugin.
abstract class AudioCodecPlatform extends PlatformInterface {
  /// Constructs a AudioCodecPlatform.
  AudioCodecPlatform({required super.token});

  /// The default instance of [AudioCodecPlatform] to use.
  static final Object _token = Object();

  /// The default instance of [AudioCodecPlatform] to use.
  static AudioCodecPlatform _instance = MethodChanelAudioCodec(token: _token);

  /// The default instance of [AudioCodecPlatform] to use.
  static AudioCodecPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  static set instance(AudioCodecPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Stream that emits PCM data as a list of doubles.
  Stream<List<double>> get pcmDataStream;

  /// Stream that emits the current duration of the player in milliseconds.
  Stream<int> get onCurrentDurationChanged;

  /// Stream that emits when the player has ended playback.
  Stream<void> get onPlayerEnded;

  /// Returns the total duration of the audio file.
  Duration get totalDuration;

  /// Processes an audio file located at [filePath].
  Future<void> processAudioFile(String filePath);

  /// Pauses the audio player.
  Future<void> pausePlayer();

  /// Plays the audio player.
  Future<void> playPlayer();

  /// Seeks the player to a given [seekDuration].
  Future<void> seekTo(Duration seekDuration);

  /// Releases all resources held by the codec/player.
  Future<void> release();

  /// Disposes the stream controllers to avoid memory leaks.
  void dispose();
}
