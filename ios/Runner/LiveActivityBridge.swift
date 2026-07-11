import ActivityKit
import Flutter
import Foundation

/// Dart-facing bridge for the downloads Live Activity. Channel
/// "hondana/live_activity": `update` (starts the activity if needed) and
/// `end`. Silently no-ops below iOS 16.2 (ActivityContent API floor) or when
/// the user disabled
/// Live Activities.
enum LiveActivityBridge {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "hondana/live_activity",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      guard #available(iOS 16.2, *) else {
        result(nil)
        return
      }
      let args = call.arguments as? [String: Any] ?? [:]
      switch call.method {
      case "update":
        Controller.shared.update(args)
        result(nil)
      case "end":
        Controller.shared.end(immediate: args["immediate"] as? Bool ?? false)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @available(iOS 16.2, *)
  final class Controller {
    static let shared = Controller()

    private var activity: Activity<DownloadActivityAttributes>?

    private init() {
      // Re-attach to an activity that survived an app kill; end duplicates.
      let existing = Activity<DownloadActivityAttributes>.activities
      activity = existing.first
      for extra in existing.dropFirst() {
        Task { await extra.end(nil, dismissalPolicy: .immediate) }
      }
    }

    private func contentState(
      _ args: [String: Any]
    ) -> DownloadActivityAttributes.ContentState {
      DownloadActivityAttributes.ContentState(
        mangaTitle: args["mangaTitle"] as? String ?? "",
        chapterName: args["chapterName"] as? String ?? "",
        progress: args["progress"] as? Double ?? 0,
        completedPages: args["completedPages"] as? Int ?? 0,
        totalPages: args["totalPages"] as? Int ?? 0,
        queued: args["queued"] as? Int ?? 0
      )
    }

    func update(_ args: [String: Any]) {
      let content = ActivityContent(state: contentState(args), staleDate: nil)
      if let activity {
        Task { await activity.update(content) }
        return
      }
      guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
      activity = try? Activity.request(
        attributes: DownloadActivityAttributes(),
        content: content
      )
    }

    func end(immediate: Bool) {
      guard let activity else { return }
      self.activity = nil
      Task {
        await activity.end(
          nil,
          dismissalPolicy: immediate ? .immediate : .after(.now + 3)
        )
      }
    }
  }
}
