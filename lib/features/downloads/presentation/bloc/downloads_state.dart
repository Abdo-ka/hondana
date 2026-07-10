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
  });

  final int chapterId;
  final int mangaId;
  final String mangaTitle;
  final String chapterName;
  final DownloadTaskStatus status;

  /// 0..1 page progress.
  final double progress;

  bool get isActive =>
      status == DownloadTaskStatus.queued ||
      status == DownloadTaskStatus.downloading;

  DownloadTask copyWith({DownloadTaskStatus? status, double? progress}) =>
      DownloadTask(
        chapterId: chapterId,
        mangaId: mangaId,
        mangaTitle: mangaTitle,
        chapterName: chapterName,
        status: status ?? this.status,
        progress: progress ?? this.progress,
      );

  @override
  List<Object?> get props =>
      [chapterId, mangaId, mangaTitle, chapterName, status, progress];
}

@immutable
class DownloadsState extends Equatable {
  const DownloadsState({this.queue = const [], this.downloaded = const {}});

  final List<DownloadTask> queue;

  /// Chapter ids fully present on disk.
  final Set<int> downloaded;

  DownloadTask? taskFor(int chapterId) =>
      queue.firstWhereOrNull((t) => t.chapterId == chapterId);

  DownloadsState copyWith({List<DownloadTask>? queue, Set<int>? downloaded}) =>
      DownloadsState(
        queue: queue ?? this.queue,
        downloaded: downloaded ?? this.downloaded,
      );

  @override
  List<Object?> get props => [queue, downloaded];
}
