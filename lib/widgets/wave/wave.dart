import 'package:flutter/material.dart';

/// A widget that displays an animated waveform.
///
/// The [Wave] widget uses [CustomPaint] to render a series of vertical lines representing
/// the waveform data, with an optional animation effect for the last few lines.
class Wave extends StatelessWidget {
  /// The data points representing the waveform. Each value should be between 0.0 and 50.0,
  /// where 50.0 represents the maximum height.
  final List<double> waveData;

  /// The color of the waveform lines.
  final Color color;

  /// The width of the waveform widget.
  final double width;

  /// The height of the waveform widget.
  final double height;

  /// The current animation value (between 0.0 and 1.0) to animate the last few lines of the waveform.
  final double animationValue;

  /// The number of vertical lines to draw in the waveform.
  final int lineCount;

  /// Creates a Wave widget to display the waveform with optional animation.
  ///
  /// The [waveData] and [animationValue] must be provided, and represent the waveform data
  /// and animation state, respectively. The [color], [width], [height], and [lineCount] can be customized.
  const Wave({
    super.key,
    required this.waveData,
    this.color = Colors.blue, // Default waveform color is blue.
    this.width = 300, // Default width of the waveform is 300.
    this.height = 100, // Default height of the waveform is 100.
    required this.animationValue,
    this.lineCount = 57, // Default number of lines in the waveform is 57.
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Sets the width of the waveform widget.
      height: height, // Sets the height of the waveform widget.
      child: CustomPaint(
        // Uses a custom painter to draw the waveform.
        painter: WavePainter(
          waveData: waveData,
          color: color,
          animationValue: animationValue,
          lineCount: lineCount,
        ),
      ),
    );
  }
}

/// Custom painter class for drawing the waveform.
///
/// The [WavePainter] draws a series of vertical lines based on the provided
/// waveform data, with the last few lines being animated based on the [animationValue].
class WavePainter extends CustomPainter {
  /// The data points representing the waveform heights.
  final List<double> waveData;

  /// The color of the waveform lines.
  final Color color;

  /// The current animation value (between 0.0 and 1.0).
  final double animationValue;

  /// The number of lines to draw in the waveform.
  final int lineCount;

  /// The number of lines at the end of the waveform to animate.
  static const int _animatedLineCount = 5;

  /// Creates a [WavePainter] with the specified parameters.
  WavePainter({
    required this.waveData,
    required this.color,
    required this.animationValue,
    required this.lineCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Defines the paint object with the specified color, stroke width, and stroke cap.
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Spacing between each vertical line.
    final lineSpacing = size.width / (lineCount - 1);

    // The vertical center of the widget.
    final centerY = size.height / 2;

    // Draws the waveform lines.
    for (int i = 0; i < lineCount; i++) {
      // Determines the line height based on the waveData or sets it to 0 if there's no data.
      final lineHeight = i < waveData.length ? waveData[i] * size.height * 2.0 : 0;

      // Calculates the start and end points of the vertical line.
      final startY = centerY - lineHeight / 2;
      final endY = centerY + lineHeight / 2;

      // Animates the last few lines of the waveform.
      final isAnimated = i > waveData.length - _animatedLineCount;
      final animatedStartY = isAnimated ? _interpolate(centerY, startY, animationValue) : startY;
      final animatedEndY = isAnimated ? _interpolate(centerY, endY, animationValue) : endY;

      // Draws the line on the canvas.
      canvas.drawLine(
        Offset(i * lineSpacing, animatedStartY),
        Offset(i * lineSpacing, animatedEndY),
        paint,
      );
    }
  }

  /// Linearly interpolates between two values [start] and [end], based on the given [t] value.
  ///
  /// The [t] parameter is the animation value between 0.0 and 1.0, where 0.0 represents the
  /// start of the animation and 1.0 represents the end.
  double _interpolate(double start, double end, double t) => start + (end - start) * t;

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    // Repaints the waveform if any of the parameters change.
    return oldDelegate.waveData != waveData ||
        oldDelegate.color != color ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.lineCount != lineCount;
  }
}
