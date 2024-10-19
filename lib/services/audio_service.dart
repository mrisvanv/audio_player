import 'dart:io';

import 'package:audio_player/repositories/audio/audio_repository_impl.dart';
import 'package:path_provider/path_provider.dart';

/// A service class responsible for handling audio download operations.
class AudioService {
  /// Downloads an audio file with the provided [onProgress] callback for monitoring progress.
  ///
  /// The [onProgress] callback provides a progress update between 0.0 (start) and 1.0 (completion)
  /// while the audio file is being downloaded.
  ///
  /// Returns a [File] representing the downloaded audio file.
  Future<File> downloadAudio(Function(double) onProgress) async {
    const String audioFileName = 'background music.mp3';
    final Directory tempDirectory = await getApplicationDocumentsDirectory();

    return AudioRepositoryImpl().getAudio(
      fileName: audioFileName,
      tempDirectory: tempDirectory,
      onProgress: onProgress,
    );
  }
}
