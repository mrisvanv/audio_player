import 'package:audio_player/main.dart' as app;
import 'package:audio_player/widgets/progress_indicator/download_progress_indicator.dart';
import 'package:audio_player/widgets/visualizer/visualizer.dart';
import 'package:audio_player/widgets/wave/animated_wave.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  // Ensure the binding for integration tests is initialized
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Audio Player App Integration Test', () {
    testWidgets('Full app lifecycle test', (WidgetTester tester) async {
      // Start the application
      app.main();
      await tester.pump(); // Wait for the app to render

      // Verify that we are on the home page
      dPrint('Verifying home page');
      expect(find.text('Audio Player'), findsOneWidget); // Check if the home page title is displayed

      // Test 1: Verify downloading state
      dPrint('Verifying downloading state');
      expect(find.byType(DownloadProgressIndicator), findsOneWidget); // Check for the download progress indicator
      expect(find.byType(Visualizer), findsOneWidget); // Check for the visualizer widget

      // Wait for the initial state to change (5 seconds for download simulation)
      await tester.pump(const Duration(seconds: 5));

      // Test 2: Verify state after download
      dPrint('Verifying state after download');
      expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget); // Check for the play button
      expect(find.byType(AnimatedWave), findsOneWidget); // Check for animated wave visualizer
      expect(find.byType(DownloadProgressIndicator), findsNothing); // Ensure download indicator is gone

      // Test 3: Play functionality
      dPrint('Verifying play functionality');
      await tester.tap(find.byIcon(Icons.play_circle_fill_rounded)); // Tap the play button
      await tester.pumpAndSettle(); // Wait for animations to complete
      expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget); // Check for pause button

      final progressBar = find.byKey(const Key('progressBar')); // Find the progress bar
      expect(progressBar, findsOneWidget); // Ensure progress bar is present

      final Container progressBarWidget = tester.widget(progressBar); // Get the progress bar widget
      expect(progressBarWidget.constraints!.minWidth, greaterThan(0)); // Ensure progress bar width is greater than 0

      // Test 4: Pause functionality
      dPrint('Verifying pause functionality');
      await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded)); // Tap the pause button
      await tester.pumpAndSettle(); // Wait for animations to complete
      expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget); // Check for play button

      final progressBar2 = find.byKey(const Key('progressBar')); // Find the progress bar again
      expect(progressBar2, findsOneWidget); // Ensure progress bar is present

      final Container progressBarWidget2 = tester.widget(progressBar2); // Get the progress bar widget
      expect(progressBarWidget2.constraints!.minWidth, greaterThan(90)); // Ensure progress bar width is greater than 90

      // Test 5: Play again and auto-pause
      dPrint('Verifying auto-pause functionality on completion');
      await tester.tap(find.byIcon(Icons.play_circle_fill_rounded)); // Tap play button again
      await tester.pumpAndSettle(); // Wait for animations to complete

      // Wait for the audio to complete (15 seconds simulation)
      await tester.pump(const Duration(seconds: 15));
      expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget); // Check for play button after completion

      final progressBarAgain = find.byKey(const Key('progressBar')); // Find the progress bar again
      expect(progressBarAgain, findsOneWidget); // Ensure progress bar is present

      final Container progressBarWidgetAgain = tester.widget(progressBarAgain); // Get the progress bar widget
      expect(
          progressBarWidgetAgain.constraints!.minWidth, equals(0)); // Ensure progress bar width is 0 after completion

      // Test 6: Verify waveform
      dPrint('Verifying waveform');
      expect(find.byType(Visualizer), findsOneWidget); // Ensure the visualizer is present
      expect(find.byType(AnimatedWave), findsOneWidget); // Ensure the animated wave widget is present
    });
  });
}
void dPrint(String message) {
  if (kDebugMode) {
    print(message);
  }
}
