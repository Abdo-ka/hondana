import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LiveActivityBridge") {
      LiveActivityBridge.register(messenger: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativeScreen") {
      registerNativeScreenChannel(messenger: registrar.messenger())
    }
  }

  /// Reader screen controls: keep-awake + brightness ("hondana/native").
  private func registerNativeScreenChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "hondana/native", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      let args = call.arguments as? [String: Any] ?? [:]
      switch call.method {
      case "keepScreenOn":
        UIApplication.shared.isIdleTimerDisabled = args["on"] as? Bool ?? false
        result(nil)
      case "setBrightness":
        if let value = args["value"] as? Double {
          UIScreen.main.brightness = CGFloat(min(max(value, 0), 1))
        }
        // nil = restore: iOS has no "system" value to restore to — the reader
        // saves getBrightness() on entry and sets it back explicitly.
        result(nil)
      case "getBrightness":
        result(Double(UIScreen.main.brightness))
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
