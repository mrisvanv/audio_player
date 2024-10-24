import 'dart:async';

import 'package:audio_player/blocs/audio_player/audio_player_bloc.dart';
import 'package:audio_player/blocs/audio_player/audio_player_state.dart';
import 'package:audio_player/screens/home_page/home_page.dart';
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

  /// Tests that the HomePage displays an AssetImage's Container decoration
  testWidgets('HomePage displays an AssetImage Container', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byKey(Key('background_image')), findsOneWidget); // Verify the Container is displayed
  });

  /// Tests that the HomePage displays the audio_player_container widget.
  testWidgets('HomePage displays audio_player_container', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byKey(Key('audio_player_container')), findsOneWidget); // Verify the Visualizer widget is displayed
  });

  /// Tests that the Visualizer displays a play button when paused.
  testWidgets('Visualizer displays play button when paused', (WidgetTester tester) async {
    // Mock the state to indicate the audio player is paused
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState().copyWith(
      status: AudioPlayerStatus.paused,
    ));
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget); // Verify play button is shown
  });

  /// Tests that the Visualizer displays a pause button when playing.
  testWidgets('Visualizer displays pause button when playing', (WidgetTester tester) async {
    // Mock the state to indicate the audio player is playing
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState().copyWith(
      status: AudioPlayerStatus.playing,
    ));
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.pause_rounded), findsOneWidget); // Verify pause button is shown
  });

  /// Tests that the Homepage displays a Text field with Loading... when downloading.
  testWidgets('Homepage displays Loading... when downloading', (WidgetTester tester) async {
    // Mock the state to indicate downloading with progress
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState().copyWith(
      status: AudioPlayerStatus.loading,
      downloadProgress: 0.5,
    ));
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Loading...'), findsOneWidget); // Verify the loading text is displayed
  });

  /// Tests that the play/pause button triggers the PlayPauseAudio event in the bloc.
  testWidgets('Play/Pause button triggers PlayPauseAudio event', (WidgetTester tester) async {
    // Arrange: Set the initial state to paused
    when(mockAudioPlayerBloc.state).thenReturn(AudioPlayerState(status: AudioPlayerStatus.paused));

    // Act: Build the widget and find the play button
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for animations to settle

    final playButton = find.byIcon(Icons.play_arrow_rounded);
    expect(playButton, findsOneWidget); // Verify the play button is displayed
    await tester.tap(playButton); // Tap the play button
    await tester.pump(); // Rebuild the widget tree

    // Assert: Verify that the PlayPauseAudio event was added to the bloc
    verify(mockAudioPlayerBloc.add(any)).called(1);
  });

}
