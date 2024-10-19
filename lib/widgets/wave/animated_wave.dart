import 'package:audio_player/widgets/wave/wave.dart';
import 'package:flutter/material.dart';

/// A widget that animates a wave form based on provided data.
///
/// The wave animation starts with an initial value of 0 and progresses to 1 over
/// a specified duration. The wave data, color, width, and height can be customized.
class AnimatedWave extends StatefulWidget {
  /// The list of data points that represent the waveform.
  final List<double> waveData;

  /// The color of the wave.
  final Color color;

  /// The width of the wave widget.
  final double width;

  /// The height of the wave widget.
  final double height;

  /// Creates an [AnimatedWave] widget.
  ///
  /// The [waveData] is required, while [color], [width], and [height] have default values.
  const AnimatedWave({
    super.key,
    required this.waveData,
    this.color = Colors.blue,
    this.width = 300,
    this.height = 100,
  });

  @override
  AnimatedWaveState createState() => AnimatedWaveState();
}

/// The state class for [AnimatedWave].
///
/// It manages the animation of the wave using an [AnimationController].
class AnimatedWaveState extends State<AnimatedWave> with SingleTickerProviderStateMixin {
  /// Controls the animation progress.
  late final AnimationController _controller;

  /// Represents the animation progress value between 0 and 1.
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a duration of 500 milliseconds.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Define the animation tween from 0 to 1 and start the animation.
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward(); // Start the animation immediately.
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is destroyed to free up resources.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder rebuilds the widget every time the animation value changes.
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Pass the current animation value to the Wave widget for rendering.
        return Wave(
          waveData: widget.waveData,
          color: widget.color,
          width: widget.width,
          height: widget.height,
          animationValue: _animation.value,
        );
      },
    );
  }
}
