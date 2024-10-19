import 'dart:async';

import 'package:audio_player/blocs/audio_player/audio_player_bloc.dart';
import 'package:audio_player/blocs/audio_player/audio_player_state.dart';
import 'package:audio_player/screens/home_page/home_page.dart';
import 'package:audio_player/widgets/progress_indicator/download_progress_indicator.dart';
import 'package:audio_player/widgets/visualizer/visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_page_test.mocks.dart';

// Generate mocks for the AudioPlayerBloc class
@GenerateMocks([AudioPlayerBloc])
void main() {
  late MockAudioPlayerBloc mockAudioPlayerBloc; // Mock of the AudioPlayerBloc
  late StreamController<AudioPlayerState> streamController; // Controller for the AudioPlayerState stream

  // Set up the test environment before each test
  setUp(() {
    mockAudioPlayerBloc = MockAudioPlayerBloc();
    streamController = StreamController<AudioPlayerState>.broadcast();

    // Mock the bloc's stream and initial state
    when(mockAudioPlayerBloc.stream).thenAnswer((_) => streamController.stream);
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState());
  });

  // Clean up after each test
  tearDown(() {
    streamController.close();
    mockAudioPlayerBloc.close();
  });

  /// Creates a widget for testing the HomePage with a BlocProvider
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AudioPlayerBloc>(
        create: (context) => mockAudioPlayerBloc,
        child: const HomePage(), // The widget under test
      ),
    );
  }

  /// Tests that the HomePage displays an AppBar with the correct title.
  testWidgets('HomePage displays AppBar with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Audio Player'), findsOneWidget); // Verify the title is displayed
    expect(find.byType(AppBar), findsOneWidget); // Verify the AppBar is present
  });

  /// Tests that the HomePage displays the Visualizer widget.
  testWidgets('HomePage displays Visualizer widget', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(Visualizer), findsOneWidget); // Verify the Visualizer widget is displayed
  });

  /// Tests that the Visualizer displays a play button when paused.
  testWidgets('Visualizer displays play button when paused', (WidgetTester tester) async {
    // Mock the state to indicate the audio player is paused
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState().copyWith(
      status: AudioPlayerStatus.paused,
    ));
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget); // Verify play button is shown
  });

  /// Tests that the Visualizer displays a pause button when playing.
  testWidgets('Visualizer displays pause button when playing', (WidgetTester tester) async {
    // Mock the state to indicate the audio player is playing
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState().copyWith(
      status: AudioPlayerStatus.playing,
    ));
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget); // Verify pause button is shown
  });

  /// Tests that the Visualizer displays a download progress indicator when downloading.
  testWidgets('Visualizer displays download progress indicator when downloading', (WidgetTester tester) async {
    // Mock the state to indicate downloading with progress
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState().copyWith(
      status: AudioPlayerStatus.loading,
      downloadProgress: 0.5,
    ));
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(DownloadProgressIndicator), findsOneWidget); // Verify progress indicator is shown
  });

  /// Tests that the play/pause button triggers the PlayPauseAudio event in the bloc.
  testWidgets('Play/Pause button triggers PlayPauseAudio event', (WidgetTester tester) async {
    // Arrange: Set the initial state to paused
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState(status: AudioPlayerStatus.paused));

    // Act: Build the widget and find the play button
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for animations to settle

    final playButton = find.byIcon(Icons.play_circle_fill_rounded);
    expect(playButton, findsOneWidget); // Verify the play button is displayed
    await tester.tap(playButton); // Tap the play button
    await tester.pump(); // Rebuild the widget tree

    // Assert: Verify that the PlayPauseAudio event was added to the bloc
    verify(mockAudioPlayerBloc.add(any)).called(1);
  });

  /// Tests that an error message is displayed when present.
  testWidgets('Error message is displayed when present', (WidgetTester tester) async {
    const errorMessage = 'An error occurred';
    // Mock the state to include an error message
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState().copyWith(
      errorMessage: errorMessage,
    ));
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text(errorMessage), findsOneWidget); // Verify the error message is displayed
  });

  /// Tests that no error message is displayed when there is no error.
  testWidgets('Error message is not displayed when empty', (WidgetTester tester) async {
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState()); // Mock a clean state
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(Visibility), findsOneWidget); // Ensure Visibility widget is present
    expect(find.text('An error occurred'), findsNothing); // Verify the error message is not shown
  });

  /// Tests that the Visualizer displays the correct playing progress.
  testWidgets('Visualizer displays correct progress', (WidgetTester tester) async {
    const progress = 0.7;
    // Mock the state to include the playing progress
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState().copyWith(
      status: AudioPlayerStatus.playing,
      playingProgress: progress,
    ));
    await tester.pumpWidget(createWidgetUnderTest());

    final visualizer = tester.widget<Visualizer>(find.byType(Visualizer));
    expect(visualizer.progress, equals(progress)); // Verify the progress value
  });

  /// Tests that the Visualizer displays wave data correctly.
  testWidgets('Visualizer displays wave data correctly', (WidgetTester tester) async {
    final waveData = List.generate(10, (index) => index / 10); // Generate mock wave data
    // Mock the state to include the wave data
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState().copyWith(
      status: AudioPlayerStatus.playing,
      waveData: waveData,
    ));
    await tester.pumpWidget(createWidgetUnderTest());

    final visualizer = tester.widget<Visualizer>(find.byType(Visualizer));
    expect(visualizer.waveData, equals(waveData)); // Verify the wave data
  });
}
