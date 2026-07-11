import 'package:dio/dio.dart';

/// App-wide error type carried by [BlocStatus.failure]. Keeps a human [message]
/// plus the originating [exception] for logging.
class AppException implements Exception {
  const AppException({required this.message, this.exception, this.stackTrace});

  /// Human-readable text safe to surface in the UI.
  final String message;

  /// The originating error, kept for logging.
  final Object? exception;

  /// Stack trace of the originating error, when available.
  final StackTrace? stackTrace;

  /// Wraps any [error] into an [AppException], deriving a friendly [message].
  /// Returns the error unchanged if it is already an [AppException].
  factory AppException.from(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    return AppException(
      message: _describe(error),
      exception: error,
      stackTrace: stackTrace,
    );
  }

  static String _describe(Object error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => 'Connection timed out — try again',
        DioExceptionType.connectionError =>
          'Could not reach the site — check your connection',
        DioExceptionType.badResponse when code == 403 || code == 503 =>
          'Blocked by the site (HTTP $code) — open it in WebView to pass '
              'the check, then retry',
        DioExceptionType.badResponse =>
          'The site returned an error '
              '(HTTP $code)',
        DioExceptionType.cancel => 'Request cancelled',
        _ => 'Network error — try again',
      };
    }
    return error.toString();
  }

  @override
  String toString() => 'AppException($message)';
}
