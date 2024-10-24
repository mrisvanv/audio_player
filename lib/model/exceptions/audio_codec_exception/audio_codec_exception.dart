/// Exception thrown when an error occurs during audio codec operations.
///
/// The [message] describes the error in detail.
class AudioCodecException implements Exception {
  /// A message describing the error.
  final String message;

  /// Creates an [AudioCodecException] with the given [message].
  AudioCodecException(this.message);

  @override
  String toString() => 'AudioCodecException: $message';
}
