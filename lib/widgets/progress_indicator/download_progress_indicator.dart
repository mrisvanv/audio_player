import 'package:flutter/material.dart';

/// A widget that displays a pulsating download icon with progress animation.
///
/// The icon pulsates when the download is in progress, providing a visual indication
/// that the download is ongoing. Once the progress reaches 1.0, the pulsation stops.
class DownloadProgressIndicator extends StatefulWidget {
  /// The progress of the download, ranging from 0.0 to 1.0.
  final double progress;

  /// Creates a [DownloadProgressIndicator] widget.
  ///
  /// The [progress] value must be between 0.0 and 1.0.
  const DownloadProgressIndicator({
    required this.progress,
    super.key,
  });

  @override
  DownloadProgressIndicatorState createState() => DownloadProgressIndicatorState();
}

/// State for [DownloadProgressIndicator].
///
/// Handles the animation of the download icon, making it pulsate when the download
/// is in progress (i.e., when [progress] is less than 1.0).
class DownloadProgressIndicatorState extends State<DownloadProgressIndicator> with SingleTickerProviderStateMixin {
  /// Animation controller that drives the pulsating effect.
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a 1-second duration and set it to repeat in reverse.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Repeat the animation forward and backward.
  }

  @override
  void dispose() {
    // Dispose of the animation controller when the widget is destroyed to free up resources.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64, // 56 + 8 padding
      height: 64, // 56 + 8 padding
      child: Stack(
        alignment: Alignment.center,
        children: [
          // AnimatedBuilder used to update the widget's animation.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Apply a scale transformation to create the pulsating effect.
              return Transform.scale(
                scale: widget.progress < 1.0
                    ? 1 + (_controller.value * 0.1) // Pulsate when progress is less than 1.0
                    : 1, // No pulsation when download is complete
                child: const Icon(
                  Icons.download_rounded,
                  color: Color(0xff6A63FE), // Custom color for the download icon
                  size: 40, // Icon size
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
