import 'dart:io';

import 'package:audio_player/repositories/audio/audio_repository_impl.dart';
import 'package:audio_player/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_service_test.mocks.dart';

// Generate mocks for the AudioRepositoryImpl and Directory classes
@GenerateMocks([AudioRepositoryImpl, Directory])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Ensure proper widget binding for tests

  late AudioService audioService; // Instance of the service to be tested
  late MockAudioRepositoryImpl mockAudioRepositoryImpl; // Mock of the audio repository
  late MockDirectory mockDirectory; // Mock of the Directory class
  late FakePathProviderPlatform fakePathProvider; // Fake implementation of the PathProviderPlatform

  // Set up the test environment before each test
  setUp(() {
    mockAudioRepositoryImpl = MockAudioRepositoryImpl();
    mockDirectory = MockDirectory();
    fakePathProvider = FakePathProviderPlatform();
    PathProviderPlatform.instance = fakePathProvider; // Set the fake path provider

    audioService = AudioService(); // Instantiate the audio service

    // Replace the singleton instance of AudioRepositoryImpl with our mock
    AudioRepositoryImpl.instance = mockAudioRepositoryImpl;
  });

  /// Tests that downloadAudio returns a File when the audio download is successful.
  test('downloadAudio should return a File when successful', () async {
    // Arrange: Set up the expected file and mock behavior
    final mockFile = File('test_file.mp3');
    when(mockDirectory.path).thenReturn('/temp'); // Mock the directory path
    fakePathProvider.applicationDocumentsPath = Future.value('/temp'); // Set the fake path
    when(mockAudioRepositoryImpl.getAudio(
      fileName: anyNamed('fileName'),
      tempDirectory: anyNamed('tempDirectory'),
      onProgress: anyNamed('onProgress'),
    )).thenAnswer((_) async => mockFile); // Mock the getAudio method to return the mock file

    // Act: Call the method under test
    final result = await audioService.downloadAudio((progress) {});

    // Assert: Verify the result and that the expected method was called
    expect(result, equals(mockFile));
    verify(mockAudioRepositoryImpl.getAudio(
      fileName: 'background music.mp3', // Expected file name
      tempDirectory: anyNamed('tempDirectory'),
      onProgress: anyNamed('onProgress'),
    )).called(1);
  });

  /// Tests that downloadAudio calls the onProgress callback with the correct progress value.
  test('downloadAudio should call onProgress callback', () async {
    // Arrange: Set up the expected file and mock behavior
    final mockFile = File('test_file.mp3');
    when(mockDirectory.path).thenReturn('/temp');
    fakePathProvider.applicationDocumentsPath = Future.value('/temp'); // Set the fake path
    when(mockAudioRepositoryImpl.getAudio(
      fileName: anyNamed('fileName'),
      tempDirectory: anyNamed('tempDirectory'),
      onProgress: anyNamed('onProgress'),
    )).thenAnswer((invocation) async {
      final onProgress = invocation.namedArguments[#onProgress] as Function(double)?;
      onProgress?.call(0.5); // Simulate progress update
      return mockFile;
    });

    // Act: Call the method and capture progress
    double? capturedProgress;
    await audioService.downloadAudio((progress) {
      capturedProgress = progress; // Capture the progress value
    });

    // Assert: Verify that the captured progress matches the expected value
    expect(capturedProgress, equals(0.5));
  });

  /// Tests that downloadAudio throws an exception when getAudio throws an error.
  test('downloadAudio should throw when getAudio throws', () async {
    // Arrange: Set up the mock to throw an exception
    when(mockDirectory.path).thenReturn('/temp');
    fakePathProvider.applicationDocumentsPath = Future.value('/temp');
    when(mockAudioRepositoryImpl.getAudio(
      fileName: anyNamed('fileName'),
      tempDirectory: anyNamed('tempDirectory'),
      onProgress: anyNamed('onProgress'),
    )).thenThrow(Exception('Download failed')); // Simulate download failure

    // Act & Assert: Verify that calling downloadAudio throws an exception
    expect(() => audioService.downloadAudio((progress) {}), throwsException);
  });
}

// Fake implementation of PathProviderPlatform to provide controlled behavior for tests
class FakePathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  Future<String>? applicationDocumentsPath; // Simulated application documents path

  @override
  Future<String?> getApplicationDocumentsPath() {
    return applicationDocumentsPath ?? Future.value(null); // Return the simulated path
  }
}
