import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// iOS Live Activity (Dynamic Island + lock screen) mirroring the download
/// queue. No-ops on other platforms and below iOS 16.2. `update` starts the
/// activity when none is live; dedupes identical payloads so bloc emit storms
/// don't spam ActivityKit.
@lazySingleton
class LiveActivityService {
  static const _channel = MethodChannel('mihonx/live_activity');

  String _lastPayload = '';

  /// True until the first successful `end` — an activity may have survived an
  /// app kill, so the first "nothing downloading" state must clear it.
  bool _maybeLive = true;

  Future<void> update({
    required String mangaTitle,
    required String chapterName,
    required double progress,
    required int completedPages,
    required int totalPages,
    required int queued,
  }) async {
    if (!Platform.isIOS) return;
    final percent = (progress * 100).round();
    final payload = '$mangaTitle|$chapterName|$percent|$queued';
    if (payload == _lastPayload) return;
    _lastPayload = payload;
    _maybeLive = true;
    try {
      await _channel.invokeMethod<void>('update', {
        'mangaTitle': mangaTitle,
        'chapterName': chapterName,
        'progress': progress,
        'completedPages': completedPages,
        'totalPages': totalPages,
        'queued': queued,
      });
    } on PlatformException {
      // Live Activities unavailable — downloads work fine without the island.
    } on MissingPluginException {
      // Tests / platforms without the bridge.
    }
  }

  /// [immediate] dismisses at once (cancel/pause); otherwise the final state
  /// lingers a few seconds (chapter queue finished).
  Future<void> end({bool immediate = false}) async {
    if (!Platform.isIOS || !_maybeLive) return;
    _maybeLive = false;
    _lastPayload = '';
    try {
      await _channel.invokeMethod<void>('end', {'immediate': immediate});
    } on PlatformException {
      // Ignore — see update().
    } on MissingPluginException {
      // Ignore — see update().
    }
  }
}
