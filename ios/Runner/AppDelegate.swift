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

  /// Background-execution window held while the download queue hands its
  /// next chapters to URLSession after the app is hidden (BackgroundExecution).
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

  private func endBackgroundTask() {
    guard backgroundTask != .invalid else { return }
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = .invalid
  }

  /// Reader screen controls (keep-awake + brightness) and background-execution
  /// windows for the download queue ("hondana/native").
  private func registerNativeScreenChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "hondana/native", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
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
      case "beginBackgroundTask":
        if let self = self, self.backgroundTask == .invalid {
          self.backgroundTask = UIApplication.shared.beginBackgroundTask(
            withName: "hondana.downloads"
          ) { [weak self] in
            self?.endBackgroundTask()
          }
        }
        result(nil)
      case "endBackgroundTask":
        self?.endBackgroundTask()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
