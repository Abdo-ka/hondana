import 'package:flutter/services.dart';

/// Thin bridge over platform screen controls the reader needs: keep-awake
/// (Mihon "Keep screen on") and screen brightness ("Custom brightness").
/// Every call is best-effort — platforms without the channel just no-op.
abstract final class NativeScreen {
  static const _channel = MethodChannel('hondana/native');

  /// Toggles the OS keep-awake flag so the display never sleeps while reading.
  static Future<void> keepScreenOn(bool on) async {
    try {
      await _channel.invokeMethod<void>('keepScreenOn', {'on': on});
    } on PlatformException {
      // Best-effort.
    } on MissingPluginException {
      // Tests / unsupported platform.
    }
  }

  /// 0.0–1.0 sets brightness; null restores the system value.
  static Future<void> setBrightness(double? value) async {
    try {
      await _channel.invokeMethod<void>('setBrightness', {'value': value});
    } on PlatformException {
      // Best-effort.
    } on MissingPluginException {
      // Tests / unsupported platform.
    }
  }

  /// Current screen brightness 0.0–1.0, or null when unavailable.
  static Future<double?> getBrightness() async {
    try {
      return await _channel.invokeMethod<double>('getBrightness');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
