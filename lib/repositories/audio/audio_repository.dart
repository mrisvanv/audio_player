import 'dart:io';

/// An abstract class representing a repository for handling audio file operations.
abstract class AudioRepository {
  /// Retrieves an audio file from a source and stores it in a temporary directory.
  ///
  /// The [fileName] parameter specifies the name of the audio file to retrieve.
  /// The [tempDirectory] parameter specifies the directory where the audio file will be temporarily stored.
  /// The optional [onProgress] callback can be used to monitor the download or loading progress
  /// of the audio file. The progress value passed to [onProgress] is a double between 0.0 (start)
  /// and 1.0 (completion).
  ///
  /// Returns a [File] representing the retrieved audio file.
  ///
  /// Throws a [AudioRepositoryException] if the file retrieval fails.
  Future<File> getAudio({
    required String fileName,
    required Directory tempDirectory,
    Function(double)? onProgress,
  });
}
