import 'package:dio/dio.dart';

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
        DioExceptionType.receiveTimeout =>
          'Connection timed out — try again',
        DioExceptionType.connectionError =>
          'Could not reach the site — check your connection',
        DioExceptionType.badResponse when code == 403 || code == 503 =>
          'Blocked by the site (HTTP $code) — open it in WebView to pass '
              'the check, then retry',
        DioExceptionType.badResponse => 'The site returned an error '
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
