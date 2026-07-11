import 'package:background_downloader/background_downloader.dart'
    show TaskStatusUpdate;

/// Base type for every input to [DownloadsBloc].
sealed class DownloadsEvent {
  const DownloadsEvent();
}

/// Scan disk for completed downloads (run once at startup).
final class DownloadsStarted extends DownloadsEvent {
  const DownloadsStarted();
}

/// Queue a chapter for download (tapping the download button).
final class DownloadEnqueued extends DownloadsEvent {
  const DownloadEnqueued({
    required this.chapterId,
    required this.mangaId,
    required this.mangaTitle,
    required this.chapterName,
  });

  final int chapterId;
  final int mangaId;
  final String mangaTitle;
  final String chapterName;
}

/// Cancel one chapter's download (abort native tasks, keep the queue entry).
final class DownloadCancelRequested extends DownloadsEvent {
  const DownloadCancelRequested(this.chapterId);
  final int chapterId;
}

/// Re-queue a failed chapter (the retry button on a failed tile).
final class DownloadRetryRequested extends DownloadsEvent {
  const DownloadRetryRequested(this.chapterId);
  final int chapterId;
}

/// Delete a downloaded chapter's files (and drop any in-flight job).
final class DownloadDeleteRequested extends DownloadsEvent {
  const DownloadDeleteRequested({
    required this.mangaId,
    required this.chapterId,
  });
  final int mangaId;
  final int chapterId;
}

/// Remove completed/failed/cancelled entries, leaving only active ones.
final class DownloadsClearFinished extends DownloadsEvent {
  const DownloadsClearFinished();
}

/// Pause/resume queue processing (Mihon's downloads-page FAB).
final class DownloadsPauseToggled extends DownloadsEvent {
  const DownloadsPauseToggled();
}

/// Cancel every queued and in-flight download.
final class DownloadsCancelAll extends DownloadsEvent {
  const DownloadsCancelAll();
}

/// Drag-reorder of the queue list (ReorderableListView semantics).
final class DownloadsReordered extends DownloadsEvent {
  const DownloadsReordered(this.oldIndex, this.newIndex);
  final int oldIndex;
  final int newIndex;
}

/// Settings > Downloads > Only on Wi-Fi. Persists the preference and applies
/// it to running and future native tasks.
final class DownloadsWifiOnlyChanged extends DownloadsEvent {
  const DownloadsWifiOnlyChanged(this.wifiOnly);
  final bool wifiOnly;
}

/// Internal: drains the queue. Droppable — one drain loop at a time.
final class DownloadsQueueProcessed extends DownloadsEvent {
  const DownloadsQueueProcessed();
}

/// Internal: a native background page task changed status. Sequential — the
/// `.done` marker must be written exactly once, after the last page.
final class DownloadsTaskStatusChanged extends DownloadsEvent {
  const DownloadsTaskStatusChanged(this.update);
  final TaskStatusUpdate update;
}
