/// A custom exception class for errors that occur in the [AudioRepository].
///
/// The [message] parameter provides details about the error.
class AudioRepositoryException implements Exception {
  /// A message describing the error.
  final String message;

  /// Creates an [AudioRepositoryException] with the given [message].
  AudioRepositoryException(this.message);

  /// Provides a string representation of the exception, including the error message.
  @override
  String toString() => 'AudioRepositoryException: $message';
}
