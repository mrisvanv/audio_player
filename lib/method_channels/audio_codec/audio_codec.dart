import 'dart:async';

import 'package:audio_player/method_channels/audio_codec/audio_codec_interface.dart';

class AudioCodec {
  Stream<List<double>> get pcmDataStream => AudioCodecPlatform.instance.pcmDataStream;

  Stream<int> get onCurrentDurationChanged => AudioCodecPlatform.instance.onCurrentDurationChanged;

  Stream<void> get onPlayerEnded => AudioCodecPlatform.instance.onPlayerEnded;

  Duration get totalDuration => AudioCodecPlatform.instance.totalDuration;

  Future<void> processAudioFile(String filePath) async {
    return AudioCodecPlatform.instance.processAudioFile(filePath);
  }

  Future<void> pausePlayer() async {
    return AudioCodecPlatform.instance.pausePlayer();
  }

  Future<void> playPlayer() async {
    return AudioCodecPlatform.instance.playPlayer();
  }

  Future<void> seekTo(Duration seekDuration) async {
    return AudioCodecPlatform.instance.seekTo(seekDuration);
  }

  Future<void> release() async {
    return AudioCodecPlatform.instance.release();
  }

  void dispose() {
    AudioCodecPlatform.instance.dispose();
  }
}
