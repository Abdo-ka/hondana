import ActivityKit

/// Shared between Runner and the DownloadActivityExtension widget target.
/// Everything lives in ContentState (nothing fixed in the attributes) so one
/// activity can span consecutive chapters — and manga — of a download queue.
/// Text/number-only keeps the encoded state far under ActivityKit's 4KB limit
/// and means no App Group is needed.
@available(iOS 16.1, *)
struct DownloadActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var mangaTitle: String
    var chapterName: String
    /// 0...1 for the chapter currently downloading.
    var progress: Double
    var completedPages: Int
    var totalPages: Int
    /// Chapters still waiting behind the active one.
    var queued: Int
  }
}
