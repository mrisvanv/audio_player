import 'dart:io';

import 'package:audio_player/model/exceptions/audio_repository_exception/audio_repository_exception.dart';
import 'package:audio_player/repositories/audio/audio_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'audio_repository_impl_test.mocks.dart';

// Generate mocks for the Client class
@GenerateMocks([Client])
void main() {
  group('AudioRepositoryImpl', () {
    late AudioRepositoryImpl audioRepository;
    late MockClient mockClient;

    // Set up the test environment before each test
    setUp(() {
      mockClient = MockClient(); // Create a mock HTTP client
      audioRepository = AudioRepositoryImpl();
      // Assuming AudioRepositoryImpl has a setter for the client
      audioRepository.client = mockClient;
    });

    // Clean up after each test if necessary
    tearDown(() {});

    // Test case to verify successful audio file download
    test('successfully downloads audio file', () async {
      const fileName = 'test_audio.mp3';
      final tempDirectory = Directory.systemTemp; // Use system temp directory
      final filePath = '${tempDirectory.path}/$fileName'; // Construct expected file path

      // Mock the client to return a successful response
      when(mockClient.send(any)).thenAnswer((_) async {
        return StreamedResponse(
          Stream.fromIterable([List.generate(50, (index) => 0)]), // Mocking response stream
          200,
          contentLength: 100, // Mocking content length
        );
      });

      // Act: Attempt to download the audio file
      final downloadedFile = await audioRepository.getAudio(
        fileName: fileName,
        tempDirectory: tempDirectory,
      );

      // Assert: Verify that the file was downloaded and exists
      expect(downloadedFile.path, filePath);
      expect(await downloadedFile.exists(), isTrue);
    });

    // Test case to handle HTTP error responses
    test('throws AudioRepositoryException on HTTP error', () async {
      const fileName = 'test_audio.mp3';
      final tempDirectory = Directory.systemTemp;

      // Mock the client to return a 404 error
      when(mockClient.send(any)).thenAnswer((_) async {
        return StreamedResponse(Stream.empty(), 404); // Simulate HTTP 404 error
      });

      // Act & Assert: Ensure the exception is thrown with the correct message
      expect(
        () async => await audioRepository.getAudio(
          fileName: fileName,
          tempDirectory: tempDirectory,
        ),
        throwsA(isA<AudioRepositoryException>()
            .having((e) => e.message, 'message', contains('Failed to download file: HTTP 404'))),
      );
    });

    // Test case to handle network errors
    test('throws AudioRepositoryException on network error', () async {
      const fileName = 'test_audio.mp3';
      final tempDirectory = Directory.systemTemp;

      // Mock the client to throw a SocketException
      when(mockClient.send(any)).thenThrow(SocketException('No Internet'));

      // Act & Assert: Verify the correct exception is thrown for network issues
      expect(
        () async => await audioRepository.getAudio(
          fileName: fileName,
          tempDirectory: tempDirectory,
        ),
        throwsA(isA<AudioRepositoryException>()
            .having((e) => e.message, 'message', contains('Network error: No Internet'))),
      );
    });

    // Test case to handle unexpected exceptions
    test('throws AudioRepositoryException on unexpected error', () async {
      const fileName = 'test_audio.mp3';
      final tempDirectory = Directory.systemTemp;

      // Mock the client to throw a generic exception
      when(mockClient.send(any)).thenThrow(Exception('Unexpected error'));

      // Act & Assert: Ensure the exception is correctly thrown
      expect(
        () async => await audioRepository.getAudio(
          fileName: fileName,
          tempDirectory: tempDirectory,
        ),
        throwsA(isA<AudioRepositoryException>()
            .having((e) => e.message, 'message', contains('Unexpected error: Exception: Unexpected error'))),
      );
    });

    // Test case to verify download progress tracking
    test('tracks download progress', () async {
      const fileName = 'test_audio.mp3';
      final tempDirectory = Directory.systemTemp;

      int progressCalls = 0; // Count how many times the progress callback is called
      when(mockClient.send(any)).thenAnswer((_) async {
        // Mock a response with a specific content length
        final totalBytes = 100;
        return StreamedResponse(
          Stream.fromIterable(
            List.generate(5, (i) {
              // Simulate chunks of data being downloaded
              progressCalls++;
              return List.generate(totalBytes ~/ 5, (index) => 0);
            }),
          ),
          200,
          contentLength: totalBytes,
        );
      });

      // Act: Attempt to download the audio file and track progress
      await audioRepository.getAudio(
        fileName: fileName,
        tempDirectory: tempDirectory,
        onProgress: (progress) {
          // Assert: Check that the progress value is in the valid range
          expect(progress, inInclusiveRange(0.0, 1.0));
        },
      );

      // Assert: Verify that the progress callback was called the expected number of times
      expect(progressCalls, equals(5)); // Check if we received 5 progress updates
    });
  });
}
