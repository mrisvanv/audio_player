import 'package:audio_player/widgets/progress_indicator/download_progress_indicator.dart';
import 'package:audio_player/widgets/progress_indicator/wave_progress_indicator.dart';
import 'package:audio_player/widgets/wave/animated_wave.dart';
import 'package:flutter/material.dart';

/// Enum representing the current status of the visualizer.
enum VisualizerStatus { downloading, playing, paused }

/// A widget that visualizes audio playback with a wave animation and a download progress indicator.
///
/// The visualizer displays a waveform and a control button for play/pause functionality,
/// and shows download progress when a file is downloading.
class Visualizer extends StatefulWidget {
  /// Creates a [Visualizer] widget.
  ///
  /// [progress] is the current playback progress (0.0 to 1.0).
  /// [waveData] contains the data for the waveform visualization.
  /// [onPlayPause] is a callback function to handle play/pause actions.
  /// [currentStatus] indicates the current state of the visualizer.
  /// [loadingProgress] is the current progress of the download (0.0 to 1.0).
  const Visualizer({
    super.key,
    required this.progress,
    required this.waveData,
    required this.onPlayPause,
    required this.currentStatus,
    required this.loadingProgress,
  });

  /// The current playback progress from 0.0 to 1.0.
  final double progress;

  /// The data points representing the waveform.
  final List<double> waveData;

  /// Callback function for play/pause button.
  final VoidCallback onPlayPause;

  /// The current status of the visualizer.
  final VisualizerStatus currentStatus;

  /// The loading progress during download from 0.0 to 1.0.
  final double loadingProgress;

  @override
  VisualizerState createState() => VisualizerState();
}

/// State class for [Visualizer].
///
/// It manages the animation and visual representation of the audio visualizer.
class VisualizerState extends State<Visualizer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // Animation controller for progress animation.
  late Animation<double> _progressAnimation; // Animation for the progress bar.

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for visualizer progress.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Create a tween animation for smooth progress transitions.
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the animation controller to free up resources.
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Visualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation when the status changes.
    if (oldWidget.currentStatus != widget.currentStatus) {
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 120,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(6, 6),
            blurRadius: 14,
            spreadRadius: 0,
            color: Colors.black.withOpacity(0.25),
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Stack(
        children: [
          // Animated progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              double width = widget.progress > 0 ? (widget.progress == 1 ? 300 : 90 + (widget.progress * 185)) : 0;

              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  key: Key("progressBar"),
                  height: 120,
                  color: const Color(0xFFE6E6FF),
                  width: width *
                      (widget.currentStatus == VisualizerStatus.playing && widget.progress < 0.02
                          ? _progressAnimation.value
                          : 1),
                ),
              );
            },
          ),
          // Control button and wave display
          SizedBox(
            width: 300,
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  child: _buildControlButton(),
                ),
                SizedBox(
                  width: 184,
                  height: 82,
                  child: _buildWave(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the control button for play/pause functionality.
  Widget _buildControlButton() {
    if (widget.currentStatus == VisualizerStatus.downloading) {
      // Display download progress indicator when downloading.
      return SizedBox(
        width: 56,
        height: 56,
        child: DownloadProgressIndicator(progress: widget.loadingProgress),
      );
    } else {
      // Display play/pause button when playing or paused.
      return IconButton(
        onPressed: widget.onPlayPause,
        icon: Icon(
          widget.currentStatus == VisualizerStatus.paused
              ? Icons.play_circle_fill_rounded
              : Icons.pause_circle_filled_rounded,
          size: 56,
          color: const Color(0xff6A63FE),
        ),
      );
    }
  }

  /// Builds the wave visualization based on the current status.
  Widget _buildWave(BuildContext context) {
    if (widget.currentStatus == VisualizerStatus.downloading) {
      // Display wave progress indicator when downloading.
      return WaveProgressIndicator(
        progress: widget.loadingProgress,
        color: const Color(0xff9497C0),
        width: 300,
        height: 100,
      );
    } else {
      // Display animated wave visualization when playing.
      return AnimatedWave(
        waveData: widget.waveData,
        color: const Color(0xff9497C0),
        width: 300,
        height: 100,
      );
    }
  }
}
