import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A widget that displays an animated wave progress indicator.
///
/// The wave's vertical lines represent progress, and the animation creates
/// a ripple effect to make the progress visually dynamic.
class WaveProgressIndicator extends StatefulWidget {
  /// The progress value, ranging from 0.0 to 1.0.
  ///
  /// This value represents how much of the progress has been completed.
  final double progress;

  /// The color of the wave.
  final Color color;

  /// The width of the widget.
  final double width;

  /// The height of the widget.
  final double height;

  /// The number of vertical lines in the wave.
  final int lineCount;

  /// Creates a [WaveProgressIndicator] widget.
  ///
  /// The [progress] value must be between 0.0 and 1.0, inclusive.
  const WaveProgressIndicator({
    super.key,
    required this.progress,
    this.color = Colors.blue,
    this.width = 300,
    this.height = 100,
    this.lineCount = 57,
  }) : assert(progress >= 0 && progress <= 1, 'Progress must be between 0 and 1');

  @override
  WaveProgressIndicatorState createState() => WaveProgressIndicatorState();
}

/// The state for the [WaveProgressIndicator] widget.
class WaveProgressIndicatorState extends State<WaveProgressIndicator> with SingleTickerProviderStateMixin {
  /// Controller for animating the ripple effect in the progress indicator.
  late final AnimationController _rippleAnimationController;

  /// List of random offsets used for creating random variations in the wave heights.
  late final List<double> _randomOffsets;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a 1-second duration and set it to repeat.
    _rippleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Repeats animation in reverse.

    // Generate random values for the wave line heights.
    _randomOffsets = List.generate(widget.lineCount, (_) => math.Random().nextDouble());
  }

  @override
  void dispose() {
    // Dispose of the animation controller to free up resources.
    _rippleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _rippleAnimationController,
        builder: (context, _) {
          // Custom painter that draws the wave progress.
          return CustomPaint(
            painter: WaveProgressPainter(
              progress: widget.progress,
              color: widget.color,
              lineCount: widget.lineCount,
              rippleAnimationValue: _rippleAnimationController.value,
              randomOffsets: _randomOffsets,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws the animated wave progress.
///
/// Each vertical line represents a portion of the progress. The ripple effect
/// is applied to the lines near the current progress point.
class WaveProgressPainter extends CustomPainter {
  /// The current progress value.
  final double progress;

  /// The color of the wave lines.
  final Color color;

  /// The total number of vertical lines in the wave.
  final int lineCount;

  /// The value of the ripple animation, ranging from 0.0 to 1.0.
  ///
  /// This is used to animate the wave with a ripple effect.
  final double rippleAnimationValue;

  /// List of random values to create variation in wave line heights.
  final List<double> randomOffsets;

  /// Maximum height factor for the wave lines relative to the widget's height.
  static const double _maxLineHeightFactor = 0.6;

  /// Amplitude of the ripple animation effect applied to the wave lines.
  static const double _rippleAmplitude = 3.0;

  /// Creates a [WaveProgressPainter] to paint the wave progress.
  WaveProgressPainter({
    required this.progress,
    required this.color,
    required this.lineCount,
    required this.rippleAnimationValue,
    required this.randomOffsets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round; // Rounds off the ends of the lines.

    final lineSpacing = size.width / (lineCount - 1); // Horizontal spacing between lines.
    final centerY = size.height / 2; // Vertical center of the widget.
    final maxLineHeight = size.height * _maxLineHeightFactor; // Maximum possible line height.

    // Number of lines that should be fully filled based on the current progress.
    final filledLineCount = (progress * lineCount).round();

    // Draw each line in the wave.
    for (int i = 0; i < lineCount; i++) {
      final lineHeight = _calculateLineHeight(i, filledLineCount, maxLineHeight);
      final startY = centerY - lineHeight / 2;
      final endY = centerY + lineHeight / 2;

      // Draw the line on the canvas.
      canvas.drawLine(
        Offset(i * lineSpacing, startY),
        Offset(i * lineSpacing, endY),
        paint,
      );
    }
  }

  /// Calculates the height of each wave line.
  ///
  /// If the line is within the progress, its height is affected by the random
  /// offsets and ripple animation. Otherwise, the height is 0.
  double _calculateLineHeight(int index, int filledLineCount, double maxLineHeight) {
    if (index < filledLineCount) {
      // Fully filled lines use random heights and ripple offset.
      return (maxLineHeight * randomOffsets[index]) + _getRandomRippleOffset(index);
    } else if (index == filledLineCount) {
      // Partially filled line based on remaining progress.
      final partialProgress = progress * lineCount - filledLineCount.toDouble();
      return ((maxLineHeight * randomOffsets[index]) + _getRandomRippleOffset(index)) * partialProgress;
    } else {
      // No height for lines beyond the progress.
      return 0;
    }
  }

  /// Calculates the ripple offset for each line, adding the animated ripple effect.
  double _getRandomRippleOffset(int index) {
    return math.sin(randomOffsets[index] * 2 * math.pi + rippleAnimationValue * 2 * math.pi) * _rippleAmplitude;
  }

  @override
  bool shouldRepaint(covariant WaveProgressPainter oldDelegate) {
    // Repaint if the progress, color, or animation value has changed.
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        rippleAnimationValue != oldDelegate.rippleAnimationValue;
  }
}
