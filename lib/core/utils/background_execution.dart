import 'package:flutter/services.dart';

/// Bridge over iOS `UIApplication.beginBackgroundTask`: asks the OS for a short
/// window (~30 s) of extra execution time after the app leaves the foreground,
/// so in-progress Dart work (e.g. handing the next chapters to the background
/// downloader) can finish before the isolate is suspended.
///
/// At most one window is held at a time; [end] is idempotent. Best-effort —
/// Android and tests have no such call and simply no-op.
abstract final class BackgroundExecution {
  static const _channel = MethodChannel('hondana/native');

  /// Requests a background-execution window (no-op if one is already held).
  static Future<void> begin() => _invoke('beginBackgroundTask');

  /// Releases the window requested by [begin], if any.
  static Future<void> end() => _invoke('endBackgroundTask');

  static Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on PlatformException {
      // Best-effort.
    } on MissingPluginException {
      // Tests / unsupported platform.
    }
  }
}
