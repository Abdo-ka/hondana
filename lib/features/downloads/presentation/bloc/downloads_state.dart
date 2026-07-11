import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum DownloadTaskStatus { queued, downloading, completed, failed, cancelled }

class DownloadTask extends Equatable {
  const DownloadTask({
    required this.chapterId,
    required this.mangaId,
    required this.mangaTitle,
    required this.chapterName,
    this.status = DownloadTaskStatus.queued,
    this.progress = 0,
    this.error,
  });

  final int chapterId;
  final int mangaId;
  final String mangaTitle;
  final String chapterName;
  final DownloadTaskStatus status;

  /// 0..1 page progress.
  final double progress;

  /// Why the download failed — shown only while [status] is failed.
  final String? error;

  bool get isActive =>
      status == DownloadTaskStatus.queued ||
      status == DownloadTaskStatus.downloading;

  DownloadTask copyWith({
    DownloadTaskStatus? status,
    double? progress,
    String? error,
  }) =>
      DownloadTask(
        chapterId: chapterId,
        mangaId: mangaId,
        mangaTitle: mangaTitle,
        chapterName: chapterName,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props =>
      [chapterId, mangaId, mangaTitle, chapterName, status, progress, error];
}

@immutable
class DownloadsState extends Equatable {
  const DownloadsState({
    this.queue = const [],
    this.downloaded = const {},
    this.paused = false,
  });

  final List<DownloadTask> queue;

  /// Chapter ids fully present on disk.
  final Set<int> downloaded;

  /// Queue processing suspended (Mihon's pause) — entries stay queued.
  final bool paused;

  bool get hasActive => queue.any((t) => t.isActive);

  DownloadTask? taskFor(int chapterId) =>
      queue.firstWhereOrNull((t) => t.chapterId == chapterId);

  DownloadsState copyWith({
    List<DownloadTask>? queue,
    Set<int>? downloaded,
    bool? paused,
  }) =>
      DownloadsState(
        queue: queue ?? this.queue,
        downloaded: downloaded ?? this.downloaded,
        paused: paused ?? this.paused,
      );

  @override
  List<Object?> get props => [queue, downloaded, paused];
}
