import 'package:flutter/material.dart';

///
class PlayPauseControl extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const PlayPauseControl({
    super.key,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Color(0xFF474747),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            // color: const Color(0x00EDEDED),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 40,
                spreadRadius: -0,
                offset: const Offset(-10, -10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Center(
              child: AnimatedCrossFade(
                firstChild: _buildPauseIcon(),
                secondChild: _buildPlayIcon(),
                crossFadeState: isPlaying ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: Duration(milliseconds: 200),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPauseIcon() {
    return Icon(
      Icons.pause_rounded,
      size: 54,
      color: const Color(0xFF525353),
    );
  }

  Widget _buildPlayIcon() {
    return Icon(
      Icons.play_arrow_rounded,
      size: 54,
      color: const Color(0xFF525353),
    );
  }
}
