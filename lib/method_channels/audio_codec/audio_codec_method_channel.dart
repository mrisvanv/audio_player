import 'dart:async';

import 'package:audio_player/method_channels/audio_codec/audio_codec_interface.dart';
import 'package:audio_player/method_channels/audio_codec/utils.dart';
import 'package:audio_player/model/exceptions/audio_codec_exception/audio_codec_exception.dart';
import 'package:flutter/services.dart';

class MethodChanelAudioCodec extends AudioCodecPlatform {
  static const MethodChannel _channel = MethodChannel('audio_codec_channel');
  final StreamController<List<double>> _pcmDataController = StreamController<List<double>>.broadcast();
  final StreamController<int> _onCurrentDurationChanged = StreamController<int>.broadcast();
  final StreamController<void> _onPlayerEnded = StreamController<void>.broadcast();
  int _sampleRate = 0;
  int _channels = 0;
  int _pcmEncodingBit = 16;
  int _totalSize = 0;
  List<double> _waveData = [];

  // Global variables for RMS calculation
  int sampleCount = 0;
  double sampleSum = 0.0;
  int currentProgress = 0;
  double progress = 0.0;
  List<double> sampleData = [];
  int expectedPoints = 100; // Number of expected points in the waveform

  MethodChanelAudioCodec({required super.token}) {
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pcmData':
        final result = call.arguments as Map;
        final pcmData = result['pcmData'] as Uint8List;
        _sampleRate = result['sampleRate'] as int;
        _channels = result['channels'] as int;
        _pcmEncodingBit = result['pcmEncodingBit'] as int;
        _totalSize += pcmData.length;
        _waveData.add(processPcmData(pcmData, _channels, _pcmEncodingBit));
        // List<double> normalizedWaveData = normalizeWaveform(_waveData);
        // _pcmDataController.add(normalizedWaveData);
        break;
      case 'processingComplete':
        // _waveData = reduceWaveformPoints(_waveData, 100);
        List<double> waveFormData = reduceWaveformPoints(_waveData, 100);
        List<double> normalizedWaveData = normalizeWaveform(waveFormData);
        _pcmDataController.add(normalizedWaveData);
      case 'currentDuration':
        final currentDuration = call.arguments as int;
        _onCurrentDurationChanged.add(currentDuration);
      case 'playerEnded':
        _onPlayerEnded.add(null);
      default:
        break;
    }
  }

  @override
  Stream<List<double>> get pcmDataStream => _pcmDataController.stream;

  @override
  Stream<int> get onCurrentDurationChanged => _onCurrentDurationChanged.stream;

  @override
  Stream<void> get onPlayerEnded => _onPlayerEnded.stream;

  @override
  Duration get totalDuration {
    if (_sampleRate > 0 && _channels > 0) {
      final bytesPerSample = _pcmEncodingBit / 8;
      final totalSamples = _totalSize / (bytesPerSample * _channels);
      return Duration(milliseconds: ((totalSamples / _sampleRate) * 1000).round());
    } else {
      return Duration.zero;
    }
  }

  @override
  Future<void> processAudioFile(String filePath) async {
    try {
      _waveData = [];
      await _channel.invokeMethod('processAudioFile', {
        'filePath': filePath,
        // 'url':'https://codeskulptor-demos.commondatastorage.googleapis.com/descent/background music.mp3'
      });
    } on PlatformException catch (e) {
      throw AudioCodecException('Failed to process audio file: ${e.message}');
    }
  }

  @override
  Future<void> pausePlayer() async {
    try {
      await _channel.invokeMethod('pausePlayer');
    } on PlatformException catch (e) {
      throw AudioCodecException('Failed to pause player: ${e.message}');
    }
  }

  @override
  Future<void> playPlayer() async {
    try {
      await _channel.invokeMethod('playPlayer');
    } on PlatformException catch (e) {
      throw AudioCodecException('Failed to pause player: ${e.message}');
    }
  }

  @override
  Future<void> seekTo(Duration seekDuration) async {
    try {
      await _channel.invokeMethod('seekTo', {'seekDuration': seekDuration.inMilliseconds});
    } on PlatformException catch (e) {
      throw AudioCodecException('Failed to seek to position: ${e.message}');
    }
  }

  @override
  Future<void> release() async {
    try {
      await _channel.invokeMethod('release');
    } on PlatformException catch (e) {
      throw AudioCodecException('Failed to release resources: ${e.message}');
    }
  }

  @override
  void dispose() {
    _pcmDataController.close();
  }
}
