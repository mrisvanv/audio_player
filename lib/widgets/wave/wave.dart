import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Custom painter class for rendering the waveform progress bar
class WaveProgressPainter extends CustomPainter {
  final List<double> waveHeights; // List of normalized wave heights (0 to 1)
  final double progress; // Current playback progress (0 to 1)
  final Color activeColor; // Color of the lines before the current progress
  final Color inactiveColor; // Color of the lines after the current progress
  final double lineWidth; // Width of each line in the waveform
  final double lineSpace; // Space between the lines
  final double plotProgress; // Controls the plot animation (0 to 1)
  final double lineHeightProgress; // Controls the height animation of the lines (0 to 1)

  WaveProgressPainter({
    required this.waveHeights,
    required this.progress,
    this.activeColor = const Color(0xFFEDEDED),
    this.inactiveColor = const Color(0xFF747578),
    this.lineWidth = 4,
    this.lineSpace = 5,
    this.plotProgress = 1.0,
    this.lineHeightProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint object used for drawing the waveform lines
    final paint = Paint()
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round; // Rounded edges for lines

    final lineUnit = lineWidth + lineSpace; // Total space per line (width + space)
    final visibleLines = (size.width / lineUnit).ceil(); // Number of lines visible in the current size
    final totalLines = waveHeights.length; // Total number of lines in the waveform
    final centerIndex = (progress * totalLines).round(); // Index corresponding to the current progress

    // Calculate the visible range of the waveform centered around the current progress
    final halfVisibleLines = visibleLines ~/ 2; // Half the number of visible lines
    final startIndex = math.max(0, centerIndex - halfVisibleLines); // Starting index for visible lines
    final endIndex = math.min(totalLines, startIndex + visibleLines); // Ending index for visible lines

    // Calculate the x-axis offset to center the waveform around the progress
    final centerOffset = size.width / 2;
    final progressOffset = (centerIndex - startIndex) * lineUnit;
    final xOffset = centerOffset - progressOffset;

    // Calculate how many lines should be drawn based on the plot animation progress
    final maxVisibleLines = endIndex - startIndex;
    final currentVisibleLines = (maxVisibleLines * plotProgress).round();

    // Draw the waveform lines with animations
    for (int i = 0; i < currentVisibleLines; i++) {
      final index = startIndex + i;
      if (index >= waveHeights.length) break;

      final x = xOffset + i * lineUnit; // X position of the current line
      if (x < -lineWidth || x > size.width + lineWidth) continue; // Skip lines that are out of view

      final heightPercent = waveHeights[index]; // Height percentage of the current line
      // Animate line height
      final currentHeight = heightPercent * size.height * lineHeightProgress;
      final startY = (size.height - currentHeight) / 2; // Calculate the start Y position
      final endY = startY + currentHeight; // Calculate the end Y position

      // Set color: active (before progress) or inactive (after progress)
      paint.color = index <= centerIndex ? activeColor : inactiveColor;

      // Draw the line on the canvas
      canvas.drawLine(
        Offset(x, startY), // Start point of the line
        Offset(x, endY), // End point of the line
        paint, // Paint settings (color, width)
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveProgressPainter oldDelegate) {
    // Repaint if progress, plot progress, line height progress, or waveHeights change
    return oldDelegate.progress != progress ||
        oldDelegate.plotProgress != plotProgress ||
        oldDelegate.lineHeightProgress != lineHeightProgress ||
        oldDelegate.waveHeights != waveHeights;
  }
}

/// Widget for displaying a waveform progress bar
class WaveProgressBar extends StatefulWidget {
  final List<double> waveHeights; // Wave heights representing the waveform
  final double progress; // Current playback progress (0 to 1)
  final Color activeColor; // Color for active lines (before progress)
  final Color inactiveColor; // Color for inactive lines (after progress)
  final double height; // Height of the progress bar
  final double width; // Width of the progress bar
  final double lineWidth; // Width of each line in the waveform
  final double lineSpace; // Space between the lines
  final Duration plotDuration; // Duration of the plot animation
  final Duration heightDuration; // Duration of the height animation
  final Function(double)? onSeekProgress; // Callback when user seeks
  final Function(double)? onSeekComplete; // Callback when user completes seek

  const WaveProgressBar({
    super.key,
    required this.waveHeights,
    required this.progress,
    this.activeColor = const Color(0xFFEDEDED),
    this.inactiveColor = const Color(0xFF747578),
    this.height = 55,
    this.width = 937,
    this.lineWidth = 4,
    this.lineSpace = 5,
    this.plotDuration = const Duration(milliseconds: 1000),
    this.heightDuration = const Duration(milliseconds: 500),
    this.onSeekProgress,
    this.onSeekComplete,
  });

  @override
  WaveProgressBarState createState() => WaveProgressBarState();
}

class WaveProgressBarState extends State<WaveProgressBar> with TickerProviderStateMixin {
  late AnimationController _plotController; // Controls the plot animation
  late AnimationController _heightController; // Controls the height animation
  bool _isDragging = false; // Tracks if the user is currently dragging to seek
  double _dragProgress = 0.0; // Current progress during drag
  Offset? _dragStartOffset; // Starting position of the drag
  double? _dragStartProgress; // Progress when drag started

  @override
  void initState() {
    super.initState();
    _initializeAnimations(); // Initialize animation controllers
  }

  void _initializeAnimations() {
    // Initialize plot animation controller
    _plotController = AnimationController(
      duration: widget.plotDuration,
      vsync: this,
    );

    // Initialize height animation controller
    _heightController = AnimationController(
      duration: widget.heightDuration,
      vsync: this,
    );

    // Start animations when widget is initialized
    _startAnimations();
  }

  void _startAnimations() {
    // Start the plot and height animations from the beginning
    _plotController.forward(from: 0.0);
    _heightController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(WaveProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animations when the waveform data changes
    if (oldWidget.waveHeights != widget.waveHeights) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _plotController.dispose(); // Dispose plot animation controller
    _heightController.dispose(); // Dispose height animation controller
    super.dispose();
  }

  /// Handles the start of a drag operation (user starts seeking)
  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartOffset = details.localPosition; // Get the position where the drag started
    _dragStartProgress = widget.progress; // Store the progress at the start of the drag
    _dragProgress = widget.progress; // Initialize drag progress
  }

  /// Updates progress based on the current drag position
  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dragStartOffset == null || _dragStartProgress == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double width = renderBox.size.width; // Get the width of the progress bar
    final double dragDistance = details.localPosition.dx - _dragStartOffset!.dx; // Distance dragged
    final double progressDelta = (dragDistance / width); // Calculate progress change based on drag

    // Update the drag progress and clamp it between 0 and 1
    _dragProgress = (_dragStartProgress! - progressDelta).clamp(0.0, 1.0);
    widget.onSeekProgress?.call(_dragProgress); // Notify progress update callback
  }

  /// Handles the end of the drag operation (user finishes seeking)
  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    _dragStartOffset = null; // Clear drag start offset
    _dragStartProgress = null; // Clear drag start progress
    widget.onSeekComplete?.call(_dragProgress); // Notify seek complete callback
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart, // Register drag start handler
      onHorizontalDragUpdate: _handleDragUpdate, // Register drag update handler
      onHorizontalDragEnd: _handleDragEnd, // Register drag end handler
      child: SizedBox(
        width: widget.width, // Width of the progress bar
        height: widget.height, // Height of the progress bar
        child: ClipRect(
          child: AnimatedBuilder(
            animation: Listenable.merge([_plotController, _heightController]), // Listen to both animations
            builder: (context, child) {
              return CustomPaint(
                painter: WaveProgressPainter(
                  waveHeights: widget.waveHeights,
                  // Waveform data
                  progress: _isDragging ? _dragProgress : widget.progress,
                  // Progress (or drag progress)
                  activeColor: widget.activeColor,
                  // Color before progress
                  inactiveColor: widget.inactiveColor,
                  // Color after progress
                  lineWidth: widget.lineWidth,
                  // Width of the lines
                  lineSpace: widget.lineSpace,
                  // Space between lines
                  plotProgress: _plotController.value,
                  // Animation progress for plotting lines
                  lineHeightProgress: _heightController.value, // Animation progress for line heights
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
