import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import 'package:mihonx/features/browse/data/source/http_source_base.dart';
import 'package:mihonx/features/browse/domain/source/model/s_chapter.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/downloads/domain/download_service.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_state.dart';
import 'package:mihonx/features/manga/domain/manga_repository.dart';

/// App-wide download queue (singleton — survives navigation). The page list
/// is fetched in the foreground, then each page becomes a native background
/// task (URLSession on iOS via background_downloader) so downloads continue
/// when the app is backgrounded or killed. Per-page completions are
/// aggregated back into one chapter-level [DownloadTask]; the `.done` marker
/// is written only after every page of the chapter has completed.
@lazySingleton
class DownloadsBloc extends Bloc<DownloadsEvent, DownloadsState> {
  DownloadsBloc(this._service, this._repo, this._sources)
      : super(const DownloadsState()) {
    on<DownloadsStarted>(_onStarted);
    on<DownloadEnqueued>(_onEnqueued);
    on<DownloadCancelRequested>(_onCancel);
    on<DownloadRetryRequested>(_onRetry);
    on<DownloadDeleteRequested>(_onDelete);
    on<DownloadsClearFinished>(_onClearFinished);
    on<DownloadsQueueProcessed>(_onProcess, transformer: droppable());
    on<DownloadsTaskStatusChanged>(_onTaskStatus, transformer: sequential());
    add(const DownloadsStarted());
  }

  /// Task groups are `<prefix><mangaId>_<chapterId>` so a chapter's native
  /// tasks can be cancelled as a unit and reconciled after an app kill.
  static const _groupPrefix = 'mihonx_dl_';

  final DownloadService _service;
  final MangaRepository _repo;
  final SourceManager _sources;

  /// In-flight chapters: aggregates per-page native tasks into one chapter.
  /// A chapter absent from this map ignores late native updates, which is
  /// what prevents a delete/cancel from being resurrected by a `.done` write.
  final Map<int, _ChapterJob> _jobs = {};

  /// Completes once [_onStarted] has reconciled the native task database, so
  /// native updates and new enqueues cannot race the reconciliation.
  final Completer<void> _ready = Completer<void>();

  StreamSubscription<bd.TaskUpdate>? _updatesSub;

  String _group(int mangaId, int chapterId) =>
      '$_groupPrefix${mangaId}_$chapterId';

  Future<void> _onStarted(
    DownloadsStarted event,
    Emitter<DownloadsState> emit,
  ) async {
    emit(state.copyWith(downloaded: await _service.scanDownloadedChapterIds()));
    if (_updatesSub != null) return; // Idempotent — bloc is a lazySingleton.
    // The listener must exist before resumeFromBackground() so updates
    // delivered while the app was suspended/killed are not missed.
    _updatesSub = bd.FileDownloader().updates.listen((update) {
      if (update is bd.TaskStatusUpdate && !isClosed) {
        add(DownloadsTaskStatusChanged(update));
      }
    });
    try {
      final downloader = bd.FileDownloader();
      await downloader.trackTasks();
      await downloader.resumeFromBackground();
      await _reconcile(emit);
      // Re-enqueue tasks the OS killed without delivering a status update.
      await downloader.rescheduleKilledTasks();
    } on Exception {
      // Native downloader unavailable (e.g. tests) — enqueues will surface
      // per-chapter failures instead.
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  /// Rebuilds queue entries and jobs from the downloader's persistent
  /// database after an app restart, and finishes chapters whose last pages
  /// completed while the app was dead.
  Future<void> _reconcile(Emitter<DownloadsState> emit) async {
    final downloader = bd.FileDownloader();
    final byChapter = <int, List<bd.TaskRecord>>{};
    for (final record in await downloader.database.allRecords()) {
      if (!record.task.group.startsWith(_groupPrefix)) continue;
      final meta = _PageMeta.tryParse(record.task.metaData);
      if (meta == null) {
        await downloader.database.deleteRecordWithId(record.taskId);
        continue;
      }
      byChapter.putIfAbsent(meta.chapterId, () => []).add(record);
    }
    final resurrected = <DownloadTask>[];
    for (final MapEntry(key: chapterId, value: records) in byChapter.entries) {
      final meta = _PageMeta.tryParse(records.first.task.metaData)!;
      if (state.downloaded.contains(chapterId) ||
          state.taskFor(chapterId) != null) {
        await _deleteRecords(records.map((r) => r.taskId));
        continue;
      }
      final completed = records
          .where((r) => r.status == bd.TaskStatus.complete)
          .map((r) => r.taskId)
          .toSet();
      if (completed.length == meta.totalPages) {
        await _service.markDone(meta.mangaId, chapterId);
        emit(state.copyWith(downloaded: {...state.downloaded, chapterId}));
        await _deleteRecords(records.map((r) => r.taskId));
        continue;
      }
      final active = records.any((r) => r.status.isNotFinalState);
      if (active && records.length == meta.totalPages) {
        _jobs[chapterId] = _ChapterJob(
          mangaId: meta.mangaId,
          chapterId: chapterId,
          totalPages: meta.totalPages,
          taskIds: records.map((r) => r.taskId).toSet(),
          completed: completed,
        );
        resurrected.add(DownloadTask(
          chapterId: chapterId,
          mangaId: meta.mangaId,
          mangaTitle: meta.mangaTitle,
          chapterName: meta.chapterName,
          status: DownloadTaskStatus.downloading,
          progress: completed.length / meta.totalPages,
        ));
        continue;
      }
      // Finished incomplete, or pages were never enqueued before the kill —
      // the chapter can no longer complete. Surface as failed, clean up.
      await downloader.cancelAll(group: _group(meta.mangaId, chapterId));
      await _deleteRecords(records.map((r) => r.taskId));
      await _service.delete(meta.mangaId, chapterId);
      resurrected.add(DownloadTask(
        chapterId: chapterId,
        mangaId: meta.mangaId,
        mangaTitle: meta.mangaTitle,
        chapterName: meta.chapterName,
        status: DownloadTaskStatus.failed,
      ));
    }
    if (resurrected.isNotEmpty) {
      emit(state.copyWith(queue: [...state.queue, ...resurrected]));
    }
  }

  void _onEnqueued(DownloadEnqueued event, Emitter<DownloadsState> emit) {
    if (state.downloaded.contains(event.chapterId)) return;
    final existing = state.taskFor(event.chapterId);
    if (existing != null && existing.isActive) return;
    emit(state.copyWith(queue: [
      ...state.queue.where((t) => t.chapterId != event.chapterId),
      DownloadTask(
        chapterId: event.chapterId,
        mangaId: event.mangaId,
        mangaTitle: event.mangaTitle,
        chapterName: event.chapterName,
      ),
    ]));
    add(const DownloadsQueueProcessed());
  }

  Future<void> _onCancel(
    DownloadCancelRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    _update(emit, event.chapterId,
        (t) => t.copyWith(status: DownloadTaskStatus.cancelled));
    await _abortNative(event.chapterId);
  }

  void _onRetry(DownloadRetryRequested event, Emitter<DownloadsState> emit) {
    _update(emit, event.chapterId,
        (t) => t.copyWith(status: DownloadTaskStatus.queued, progress: 0));
    add(const DownloadsQueueProcessed());
  }

  Future<void> _onDelete(
    DownloadDeleteRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    // Drop the job first (a late page completion can no longer write `.done`)
    // and cancel the chapter's native tasks before removing files.
    await _abortNative(event.chapterId);
    await _service.delete(event.mangaId, event.chapterId);
    emit(state.copyWith(
      downloaded: {...state.downloaded}..remove(event.chapterId),
      queue:
          state.queue.where((t) => t.chapterId != event.chapterId).toList(),
    ));
  }

  void _onClearFinished(
    DownloadsClearFinished event,
    Emitter<DownloadsState> emit,
  ) {
    emit(state.copyWith(
      queue: state.queue.where((t) => t.isActive).toList(),
    ));
  }

  Future<void> _onProcess(
    DownloadsQueueProcessed event,
    Emitter<DownloadsState> emit,
  ) async {
    await _ready.future; // Never enqueue before reconciliation finished.
    while (true) {
      final next = state.queue
          .where((t) => t.status == DownloadTaskStatus.queued)
          .firstOrNull;
      if (next == null) return;
      _update(emit, next.chapterId,
          (t) => t.copyWith(status: DownloadTaskStatus.downloading, progress: 0));
      try {
        await _startChapter(next, emit);
      } on Exception {
        _jobs.remove(next.chapterId);
        _update(emit, next.chapterId,
            (t) => t.copyWith(status: DownloadTaskStatus.failed));
      }
    }
  }

  /// Fetches the page list (foreground) and enqueues one native background
  /// task per page, batched in page order — `pNNNN` filenames keep ordering
  /// authoritative regardless of native completion order.
  Future<void> _startChapter(
    DownloadTask task,
    Emitter<DownloadsState> emit,
  ) async {
    final chapter = await _repo.getChapter(task.chapterId);
    final manga =
        chapter == null ? null : await _repo.getManga(chapter.mangaId);
    final source = manga == null ? null : _sources.get(manga.source);
    if (chapter == null || manga == null || source == null) {
      _update(emit, task.chapterId,
          (t) => t.copyWith(status: DownloadTaskStatus.failed));
      return;
    }
    final pages = await source
        .getPageList(SChapter(url: chapter.url, name: chapter.name));
    // Cancel/delete may have landed while the page list was loading.
    if (state.taskFor(task.chapterId)?.status !=
        DownloadTaskStatus.downloading) {
      await _service.delete(task.mangaId, task.chapterId);
      return;
    }
    final urls = pages
        .map((page) => page.imageUrl ?? page.url ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
    if (urls.isEmpty) {
      _update(emit, task.chapterId,
          (t) => t.copyWith(status: DownloadTaskStatus.failed));
      return;
    }

    // Fresh directory: clears partials left by an earlier failed/cancelled run.
    await _service.delete(task.mangaId, task.chapterId);
    final dir = await _service.chapterDir(task.mangaId, task.chapterId);
    dir.createSync(recursive: true);

    final headers = <String, String>{
      'User-Agent': HttpSourceBase.userAgent,
      if (source is HttpSourceBase) ...source.imageHeaders,
    };
    final group = _group(task.mangaId, task.chapterId);
    final metaData = jsonEncode({
      'mangaId': task.mangaId,
      'chapterId': task.chapterId,
      'totalPages': urls.length,
      'mangaTitle': task.mangaTitle,
      'chapterName': task.chapterName,
    });
    final job = _ChapterJob(
      mangaId: task.mangaId,
      chapterId: task.chapterId,
      totalPages: urls.length,
    );
    final tasks = <bd.DownloadTask>[];
    for (var i = 0; i < urls.length; i++) {
      final url = urls[i];
      final taskId = '$group-p${i + 1}';
      final filename =
          'p${(i + 1).toString().padLeft(4, '0')}${_extension(url)}';
      job.taskIds.add(taskId);
      if (!url.startsWith('http')) {
        // Local page (already on disk, e.g. source-side cache) — copy inline.
        await File(url).copy(p.join(dir.path, filename));
        job.completed.add(taskId);
        continue;
      }
      tasks.add(bd.DownloadTask(
        taskId: taskId,
        url: url,
        headers: headers,
        baseDirectory: bd.BaseDirectory.applicationDocuments,
        directory: _service.relativeChapterDir(task.mangaId, task.chapterId),
        filename: filename,
        group: group,
        updates: bd.Updates.status,
        retries: 2,
        metaData: metaData,
      ));
    }
    _jobs[task.chapterId] = job;
    if (tasks.isEmpty) {
      // Every page was local — the chapter is already complete.
      await _finishChapter(job, emit);
      return;
    }
    // A cancel/delete may have interleaved with the local-page copies above.
    if (state.taskFor(task.chapterId)?.status !=
        DownloadTaskStatus.downloading) {
      _jobs.remove(task.chapterId);
      await _service.delete(task.mangaId, task.chapterId);
      return;
    }
    final enqueued = await bd.FileDownloader().enqueueAll(tasks);
    if (enqueued.contains(false)) await _failChapter(task.chapterId, emit);
  }

  Future<void> _onTaskStatus(
    DownloadsTaskStatusChanged event,
    Emitter<DownloadsState> emit,
  ) async {
    await _ready.future;
    final update = event.update;
    if (!update.task.group.startsWith(_groupPrefix)) return;
    final meta = _PageMeta.tryParse(update.task.metaData);
    if (meta == null) return;
    final job = _jobs[meta.chapterId];
    if (job == null) {
      // Chapter no longer tracked (deleted/cancelled/failed): remove the
      // stray page file so a delete cannot leave freshly-landed partials,
      // then drop the record. Never touch chapters that are fully done.
      if (update.status == bd.TaskStatus.complete &&
          !state.downloaded.contains(meta.chapterId)) {
        final file = File(await update.task.filePath());
        if (file.existsSync()) await file.delete();
      }
      if (update.status.isFinalState) {
        await bd.FileDownloader().database.deleteRecordWithId(
              update.task.taskId,
            );
      }
      return;
    }
    switch (update.status) {
      case bd.TaskStatus.complete:
        job.completed.add(update.task.taskId);
        if (job.completed.length >= job.totalPages) {
          await _finishChapter(job, emit);
        } else {
          _update(emit, job.chapterId,
              (t) => t.copyWith(progress: job.completed.length / job.totalPages));
        }
      case bd.TaskStatus.failed:
      case bd.TaskStatus.notFound:
      case bd.TaskStatus.canceled:
        // canceled with a live job means the OS killed the task — user
        // cancels remove the job before native cancellation runs.
        await _failChapter(job.chapterId, emit);
      case bd.TaskStatus.enqueued:
      case bd.TaskStatus.running:
      case bd.TaskStatus.waitingToRetry:
      case bd.TaskStatus.paused:
        break;
    }
  }

  Future<void> _finishChapter(
    _ChapterJob job,
    Emitter<DownloadsState> emit,
  ) async {
    _jobs.remove(job.chapterId);
    await _service.markDone(job.mangaId, job.chapterId);
    await _deleteRecords(job.taskIds);
    _update(emit, job.chapterId,
        (t) => t.copyWith(status: DownloadTaskStatus.completed, progress: 1));
    emit(state.copyWith(downloaded: {...state.downloaded, job.chapterId}));
  }

  Future<void> _failChapter(int chapterId, Emitter<DownloadsState> emit) async {
    final job = _jobs.remove(chapterId);
    if (job != null) {
      await bd.FileDownloader()
          .cancelAll(group: _group(job.mangaId, chapterId));
      await _deleteRecords(job.taskIds);
      // Failed downloads never keep partial pages on disk.
      await _service.delete(job.mangaId, chapterId);
    }
    _update(emit, chapterId,
        (t) => t.copyWith(status: DownloadTaskStatus.failed));
  }

  /// Cancels a chapter's native tasks, forgets its job and removes partials.
  Future<void> _abortNative(int chapterId) async {
    final job = _jobs.remove(chapterId);
    if (job == null) return;
    await bd.FileDownloader().cancelAll(group: _group(job.mangaId, chapterId));
    await _deleteRecords(job.taskIds);
    await _service.delete(job.mangaId, chapterId);
  }

  Future<void> _deleteRecords(Iterable<String> taskIds) async {
    final database = bd.FileDownloader().database;
    for (final taskId in taskIds) {
      await database.deleteRecordWithId(taskId);
    }
  }

  String _extension(String url) {
    final ext = p.extension(Uri.parse(url).path).toLowerCase();
    const known = {'.jpg', '.jpeg', '.png', '.webp', '.gif', '.avif', '.bmp'};
    return known.contains(ext) ? ext : '.jpg';
  }

  void _update(
    Emitter<DownloadsState> emit,
    int chapterId,
    DownloadTask Function(DownloadTask) fn,
  ) {
    emit(state.copyWith(
      queue: state.queue
          .map((t) => t.chapterId == chapterId ? fn(t) : t)
          .toList(),
    ));
  }

  @override
  Future<void> close() async {
    await _updatesSub?.cancel();
    return super.close();
  }
}

/// Aggregation record for one chapter's native page tasks.
class _ChapterJob {
  _ChapterJob({
    required this.mangaId,
    required this.chapterId,
    required this.totalPages,
    Set<String>? taskIds,
    Set<String>? completed,
  })  : taskIds = taskIds ?? {},
        completed = completed ?? {};

  final int mangaId;
  final int chapterId;
  final int totalPages;
  final Set<String> taskIds;

  /// Task ids of completed pages — a set so replayed updates stay idempotent.
  final Set<String> completed;
}

/// Chapter identity carried in each native task's `metaData` JSON, so a
/// killed app can rebuild the queue from `database.allRecords()` alone.
class _PageMeta {
  const _PageMeta({
    required this.mangaId,
    required this.chapterId,
    required this.totalPages,
    required this.mangaTitle,
    required this.chapterName,
  });

  final int mangaId;
  final int chapterId;
  final int totalPages;
  final String mangaTitle;
  final String chapterName;

  static _PageMeta? tryParse(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final mangaId = json['mangaId'];
      final chapterId = json['chapterId'];
      final totalPages = json['totalPages'];
      if (mangaId is! int || chapterId is! int || totalPages is! int) {
        return null;
      }
      return _PageMeta(
        mangaId: mangaId,
        chapterId: chapterId,
        totalPages: totalPages,
        mangaTitle: json['mangaTitle'] as String? ?? '',
        chapterName: json['chapterName'] as String? ?? '',
      );
    } on FormatException {
      return null;
    }
  }
}
