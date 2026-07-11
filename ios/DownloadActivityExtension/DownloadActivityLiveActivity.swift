import ActivityKit
import SwiftUI
import WidgetKit

/// Live Activity UI for the download queue: lock-screen banner plus Dynamic
/// Island compact/expanded/minimal presentations.
struct DownloadActivityLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: DownloadActivityAttributes.self) { context in
      // Lock screen / notification banner.
      VStack(alignment: .leading, spacing: 6) {
        HStack {
          Image(systemName: "arrow.down.circle.fill")
          Text(context.state.mangaTitle).font(.headline).lineLimit(1)
          Spacer()
          if context.state.queued > 0 {
            Text("+\(context.state.queued)")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        Text(context.state.chapterName)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(1)
        ProgressView(value: context.state.progress)
        Text("\(context.state.completedPages)/\(context.state.totalPages) pages")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      .padding()
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: "arrow.down.circle.fill").font(.title2)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text("\(Int(context.state.progress * 100))%")
            .font(.title3)
            .monospacedDigit()
        }
        DynamicIslandExpandedRegion(.center) {
          VStack(spacing: 2) {
            Text(context.state.mangaTitle).font(.headline).lineLimit(1)
            Text(context.state.chapterName)
              .font(.caption)
              .foregroundStyle(.secondary)
              .lineLimit(1)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(spacing: 4) {
            ProgressView(value: context.state.progress)
            HStack {
              Text("\(context.state.completedPages)/\(context.state.totalPages) pages")
              Spacer()
              if context.state.queued > 0 {
                Text("\(context.state.queued) queued")
              }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
          }
        }
      } compactLeading: {
        Image(systemName: "arrow.down.circle.fill")
      } compactTrailing: {
        ProgressView(value: context.state.progress)
          .progressViewStyle(.circular)
          .frame(width: 18, height: 18)
      } minimal: {
        ProgressView(value: context.state.progress)
          .progressViewStyle(.circular)
          .frame(width: 18, height: 18)
      }
    }
  }
}
