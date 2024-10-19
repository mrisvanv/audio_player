import 'dart:io';

import 'package:audio_player/model/exceptions/audio_repository_exception/audio_repository_exception.dart';
import 'package:audio_player/repositories/audio/audio_repository.dart';
import 'package:http/http.dart';

/// Implementation of the AudioRepository interface.
/// This class is responsible for downloading audio files from a remote server.
class AudioRepositoryImpl implements AudioRepository {
  static const String _audioUrl = 'https://codeskulptor-demos.commondatastorage.googleapis.com/descent/';

  // Singleton instance
  static AudioRepositoryImpl instance = AudioRepositoryImpl._internal();

  factory AudioRepositoryImpl() => instance;

  AudioRepositoryImpl._internal();

  // Late initialization of the HTTP client
  late Client client = Client();

  /// Downloads an audio file from the remote server.
  ///
  /// [fileName] is the name of the file to download.
  /// [tempDirectory] is the directory where the file will be saved.
  /// [onProgress] is an optional callback to report download progress.
  ///
  /// Returns a [Future<File>] representing the downloaded file.
  /// Throws a [AudioRepositoryException] if any error occurs during the process.
  @override
  Future<File> getAudio({
    required String fileName,
    required Directory tempDirectory,
    void Function(double progress)? onProgress,
  }) async {
    final file = File('${tempDirectory.path}/$fileName');
    final request = Request('GET', Uri.parse('$_audioUrl$fileName'));

    try {
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        final fileSink = file.openWrite();
        var downloadedBytes = 0;

        await for (final chunk in response.stream) {
          fileSink.add(chunk);
          downloadedBytes += chunk.length;
          onProgress?.call(contentLength > 0 ? downloadedBytes / contentLength : 0);
        }

        await fileSink.close();
        return file;
      } else {
        throw AudioRepositoryException('Failed to download file: HTTP ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw AudioRepositoryException('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw AudioRepositoryException('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw AudioRepositoryException('Data format error: ${e.message}');
    } catch (e) {
      throw AudioRepositoryException('Unexpected error: $e');
    } finally {
      client.close();
    }
  }
}
