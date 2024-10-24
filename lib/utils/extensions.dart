extension DurationExt on Duration {
  String toMSS() {
    int minutes = inSeconds ~/ 60;
    int seconds = inSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }
}

Duration du = Duration();
String s = du.toMSS();
