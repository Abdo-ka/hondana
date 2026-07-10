import 'package:background_downloader/background_downloader.dart'
    show TaskStatusUpdate;

sealed class DownloadsEvent {
  const DownloadsEvent();
}

/// Scan disk for completed downloads (run once at startup).
final class DownloadsStarted extends DownloadsEvent {
  const DownloadsStarted();
}

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

final class DownloadCancelRequested extends DownloadsEvent {
  const DownloadCancelRequested(this.chapterId);
  final int chapterId;
}

final class DownloadRetryRequested extends DownloadsEvent {
  const DownloadRetryRequested(this.chapterId);
  final int chapterId;
}

final class DownloadDeleteRequested extends DownloadsEvent {
  const DownloadDeleteRequested({required this.mangaId, required this.chapterId});
  final int mangaId;
  final int chapterId;
}

final class DownloadsClearFinished extends DownloadsEvent {
  const DownloadsClearFinished();
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
