/// App-wide error type carried by [BlocStatus.failure]. Keeps a human [message]
/// plus the originating [exception] for logging.
class AppException implements Exception {
  const AppException({required this.message, this.exception, this.stackTrace});

  final String message;
  final Object? exception;
  final StackTrace? stackTrace;

  factory AppException.from(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    return AppException(
      message: error.toString(),
      exception: error,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => 'AppException($message)';
}
