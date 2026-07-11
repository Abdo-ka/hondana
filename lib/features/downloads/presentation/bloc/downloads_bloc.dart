import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import 'package:hondana/core/network/app_http.dart';
import 'package:hondana/features/browse/data/source/http_source_base.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/features/downloads/domain/download_preferences.dart';
import 'package:hondana/features/downloads/domain/download_queue_store.dart';
import 'package:hondana/features/downloads/domain/download_service.dart';
import 'package:hondana/features/downloads/domain/live_activity_service.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_state.dart';
import 'package:hondana/features/manga/domain/manga_repository.dart';
import 'package:hondana/features/more/domain/security_preferences.dart';

/// App-wide download queue (singleton — survives navigation). Chapters are
/// processed one at a time in queue order (Mihon behavior — queue chapter 1
/// first and it finishes first). The active chapter's page list is fetched in
/// the foreground, then each page becomes a native background task (WorkManager
/// on Android, URLSession on iOS via background_downloader) so downloads
/// continue when the app is backgrounded or killed. Per-page completions are
/// aggregated back into one chapter-level [DownloadTask]; the `.done` marker
/// is written only after every page of the chapter has completed. The pending
/// queue itself is persisted via [DownloadQueueStore] and restored on startup,
/// so remaining chapters resume after a restart.
@lazySingleton
class DownloadsBloc extends Bloc<DownloadsEvent, DownloadsState> {
  DownloadsBloc(
    this._service,
    this._repo,
    this._sources,
    this._store,
    this._downloadPrefs,
    this._securityPrefs,
    this._liveActivity,
  ) : super(const DownloadsState()) {
    on<DownloadsStarted>(_onStarted);
    on<DownloadEnqueued>(_onEnqueued);
    on<DownloadCancelRequested>(_onCancel);
    on<DownloadRetryRequested>(_onRetry);
    on<DownloadDeleteRequested>(_onDelete);
    on<DownloadsClearFinished>(_onClearFinished);
    on<DownloadsPauseToggled>(_onPauseToggled);
    on<DownloadsCancelAll>(_onCancelAll);
    on<DownloadsReordered>(_onReordered);
    on<DownloadsWifiOnlyChanged>(_onWifiOnlyChanged);
    on<DownloadsQueueProcessed>(_onProcess, transformer: droppable());
    on<DownloadsTaskStatusChanged>(_onTaskStatus, transformer: sequential());
    add(const DownloadsStarted());
  }

  /// Task groups are `<prefix><mangaId>_<chapterId>` so a chapter's native
  /// tasks can be cancelled as a unit and reconciled after an app kill.
  static const _groupPrefix = 'hondana_dl_';

  final DownloadService _service;
  final MangaRepository _repo;
  final SourceManager _sources;
  final DownloadQueueStore _store;
  final DownloadPreferences _downloadPrefs;
  final SecurityPreferences _securityPrefs;
  final LiveActivityService _liveActivity;

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
    // Snapshot the persisted queue BEFORE any emit — the first emit and
    // `_reconcile`'s resurrected-queue emit both trigger onChange, which
    // re-saves the (then partial) queue and would otherwise clobber the
    // chapters still waiting behind the in-flight one.
    final persisted = _store.load();
    emit(
      state.copyWith(
        downloaded: await _service.scanDownloadedChapterIds(),
        paused: _store.paused,
      ),
    );
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
      final permissions = downloader.permissions;
      if (await permissions.status(bd.PermissionType.notifications) !=
          bd.PermissionStatus.granted) {
        await permissions.request(bd.PermissionType.notifications);
      }
      await downloader.trackTasks();
      // "Only on Wi-Fi": a global downloader requirement (survives restarts,
      // applies to tasks resurrected from the native DB too).
      await downloader.requireWiFi(
        _downloadPrefs.wifiOnly
            ? bd.RequireWiFi.forAllTasks
            : bd.RequireWiFi.asSetByTask,
      );
      await downloader.resumeFromBackground();
      await _reconcile(emit);
      // Re-enqueue tasks the OS killed without delivering a status update.
      await downloader.rescheduleKilledTasks();
    } on Exception {
      // Native downloader unavailable (e.g. tests) — enqueues will surface
      // per-chapter failures instead.
    } finally {
      _restoreQueue(persisted, emit);
      if (!_ready.isCompleted) _ready.complete();
      add(const DownloadsQueueProcessed());
    }
  }

  /// Re-adds chapters that were still pending when the app last stopped —
  /// reconciliation only recovers the chapter whose pages were already
  /// enqueued natively; everything behind it in the queue lives in [persisted]
  /// (snapshotted before reconciliation could re-save a partial queue).
  void _restoreQueue(
    List<DownloadTask> persisted,
    Emitter<DownloadsState> emit,
  ) {
    final restored = persisted
        .where(
          (t) =>
              !state.downloaded.contains(t.chapterId) &&
              state.taskFor(t.chapterId) == null,
        )
        .toList();
    if (restored.isNotEmpty) {
      emit(state.copyWith(queue: [...state.queue, ...restored]));
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
        resurrected.add(
          DownloadTask(
            chapterId: chapterId,
            mangaId: meta.mangaId,
            mangaTitle: meta.mangaTitle,
            chapterName: meta.chapterName,
            status: DownloadTaskStatus.downloading,
            progress: completed.length / meta.totalPages,
          ),
        );
        continue;
      }
      // Finished incomplete, or pages were never enqueued before the kill —
      // the chapter can no longer complete. Surface as failed, clean up.
      await downloader.cancelAll(group: _group(meta.mangaId, chapterId));
      await _deleteRecords(records.map((r) => r.taskId));
      await _service.delete(meta.mangaId, chapterId);
      resurrected.add(
        DownloadTask(
          chapterId: chapterId,
          mangaId: meta.mangaId,
          mangaTitle: meta.mangaTitle,
          chapterName: meta.chapterName,
          status: DownloadTaskStatus.failed,
        ),
      );
    }
    if (resurrected.isNotEmpty) {
      emit(state.copyWith(queue: [...state.queue, ...resurrected]));
    }
  }

  void _onEnqueued(DownloadEnqueued event, Emitter<DownloadsState> emit) {
    if (state.downloaded.contains(event.chapterId)) return;
    final existing = state.taskFor(event.chapterId);
    if (existing != null && existing.isActive) return;
    emit(
      state.copyWith(
        queue: [
          ...state.queue.where((t) => t.chapterId != event.chapterId),
          DownloadTask(
            chapterId: event.chapterId,
            mangaId: event.mangaId,
            mangaTitle: event.mangaTitle,
            chapterName: event.chapterName,
          ),
        ],
      ),
    );
    add(const DownloadsQueueProcessed());
  }

  Future<void> _onCancel(
    DownloadCancelRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    _update(
      emit,
      event.chapterId,
      (t) => t.copyWith(status: DownloadTaskStatus.cancelled),
    );
    await _abortNative(event.chapterId);
  }

  void _onRetry(DownloadRetryRequested event, Emitter<DownloadsState> emit) {
    _update(
      emit,
      event.chapterId,
      (t) => t.copyWith(status: DownloadTaskStatus.queued, progress: 0),
    );
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
    emit(
      state.copyWith(
        downloaded: {...state.downloaded}..remove(event.chapterId),
        queue: state.queue
            .where((t) => t.chapterId != event.chapterId)
            .toList(),
      ),
    );
  }

  void _onClearFinished(
    DownloadsClearFinished event,
    Emitter<DownloadsState> emit,
  ) {
    emit(state.copyWith(queue: state.queue.where((t) => t.isActive).toList()));
  }

  Future<void> _onProcess(
    DownloadsQueueProcessed event,
    Emitter<DownloadsState> emit,
  ) async {
    await _ready.future; // Never enqueue before reconciliation finished.
    while (true) {
      // One chapter at a time in queue order (Mihon): wait out any chapter
      // already in flight — including one resurrected after an app kill —
      // before starting the next.
      while (_jobs.isNotEmpty) {
        await _jobs.values.first.done;
      }
      if (state.paused) return;
      final next = state.queue
          .where((t) => t.status == DownloadTaskStatus.queued)
          .firstOrNull;
      if (next == null) return;
      _update(
        emit,
        next.chapterId,
        (t) => t.copyWith(status: DownloadTaskStatus.downloading, progress: 0),
      );
      try {
        await _startChapter(next, emit);
      } catch (e) {
        // Catch Error too (e.g. a StateError/TypeError from a source's
        // getPageList): an uncaught Error here would wedge the serial drain
        // with the chapter stuck at 'downloading'.
        final job = _jobs.remove(next.chapterId);
        job?.finish();
        _update(
          emit,
          next.chapterId,
          (t) => t.copyWith(status: DownloadTaskStatus.failed, error: '$e'),
        );
      }
    }
  }

  Future<void> _onPauseToggled(
    DownloadsPauseToggled event,
    Emitter<DownloadsState> emit,
  ) async {
    final paused = !state.paused;
    // Flip the flag before aborting so the drain loop can't start the next
    // chapter in the gap.
    emit(state.copyWith(paused: paused));
    if (paused) {
      // The in-flight chapter returns to queued and restarts on resume.
      // ponytail: restart, not byte-resume — pages are small images.
      final active = state.queue
          .where((t) => t.status == DownloadTaskStatus.downloading)
          .toList();
      for (final task in active) {
        await _abortNative(task.chapterId);
        _update(
          emit,
          task.chapterId,
          (t) => t.copyWith(status: DownloadTaskStatus.queued, progress: 0),
        );
      }
    } else {
      add(const DownloadsQueueProcessed());
    }
  }

  Future<void> _onCancelAll(
    DownloadsCancelAll event,
    Emitter<DownloadsState> emit,
  ) async {
    final active = state.queue.where((t) => t.isActive).toList();
    for (final task in active) {
      await _abortNative(task.chapterId);
      _update(
        emit,
        task.chapterId,
        (t) => t.copyWith(status: DownloadTaskStatus.cancelled),
      );
    }
  }

  Future<void> _onWifiOnlyChanged(
    DownloadsWifiOnlyChanged event,
    Emitter<DownloadsState> emit,
  ) async {
    await _downloadPrefs.setWifiOnly(event.wifiOnly);
    try {
      await bd.FileDownloader().requireWiFi(
        event.wifiOnly
            ? bd.RequireWiFi.forAllTasks
            : bd.RequireWiFi.asSetByTask,
        rescheduleRunningTasks: true,
      );
    } on Exception {
      // Native downloader unavailable (tests) — the pref still persisted.
    }
  }

  /// Indices arrive pre-adjusted (onReorderItem semantics).
  void _onReordered(DownloadsReordered event, Emitter<DownloadsState> emit) {
    final queue = [...state.queue];
    if (event.oldIndex < 0 || event.oldIndex >= queue.length) return;
    final task = queue.removeAt(event.oldIndex);
    queue.insert(event.newIndex.clamp(0, queue.length), task);
    emit(state.copyWith(queue: queue));
  }

  /// Fetches the page list (foreground) and enqueues one native background
  /// task per page, batched in page order — `pNNNN` filenames keep ordering
  /// authoritative regardless of native completion order.
  Future<void> _startChapter(
    DownloadTask task,
    Emitter<DownloadsState> emit,
  ) async {
    final chapter = await _repo.getChapter(task.chapterId);
    final manga = chapter == null
        ? null
        : await _repo.getManga(chapter.mangaId);
    final source = manga == null ? null : _sources.get(manga.source);
    if (chapter == null || manga == null || source == null) {
      _update(
        emit,
        task.chapterId,
        (t) => t.copyWith(
          status: DownloadTaskStatus.failed,
          error: source == null ? 'Source not installed' : 'Chapter not found',
        ),
      );
      return;
    }
    final pages = await source.getPageList(
      SChapter(url: chapter.url, name: chapter.name),
    );
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
      _update(
        emit,
        task.chapterId,
        (t) => t.copyWith(
          status: DownloadTaskStatus.failed,
          error: 'No pages found',
        ),
      );
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
    // Native download tasks bypass Dio, so the WebView cookies (Cloudflare
    // cf_clearance) must be replayed here explicitly — without them every
    // page request on a protected site 403s and the chapter fails.
    final cookieStore = cookieStoreResolver?.call();
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
      final cookie = cookieStore?.cookieHeaderFor(Uri.parse(url));
      tasks.add(
        bd.DownloadTask(
          taskId: taskId,
          url: url,
          headers: cookie == null ? headers : {...headers, 'Cookie': cookie},
          baseDirectory: bd.BaseDirectory.applicationDocuments,
          directory: _service.relativeChapterDir(task.mangaId, task.chapterId),
          filename: filename,
          group: group,
          updates: bd.Updates.status,
          retries: 2,
          metaData: metaData,
        ),
      );
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
      _jobs.remove(task.chapterId)?.finish();
      await _service.delete(task.mangaId, task.chapterId);
      return;
    }
    // One combined system notification per chapter (fixed notification id, so
    // consecutive chapters replace it) — the visible "background download".
    // iOS re-issues a group notification whenever its text changes, so the
    // body must stay static there (Android updates in place, so it can show
    // page counts and a progress bar).
    // "Hide notification content" redacts titles from the system
    // notification (the Live Activity is redacted the same way in
    // _syncLiveActivity).
    final redact = _securityPrefs.hideNotificationContent;
    bd.FileDownloader().configureNotificationForGroup(
      group,
      running: bd.TaskNotification(
        redact ? 'Downloading' : task.mangaTitle,
        redact
            ? ''
            : Platform.isIOS
            ? task.chapterName
            : '${task.chapterName} · {numFinished}/{numTotal}',
      ),
      progressBar: !Platform.isIOS,
      groupNotificationId: 'hondana_downloads',
    );
    final enqueued = await bd.FileDownloader().enqueueAll(tasks);
    // Pause/cancel/delete may have aborted the chapter during the enqueue
    // await — its cancelAll(group) ran before these tasks existed, so they'd
    // keep downloading. Cancel them now and drop the partials.
    if (!_jobs.containsKey(task.chapterId)) {
      await bd.FileDownloader().cancelAll(group: group);
      await _service.delete(task.mangaId, task.chapterId);
      return;
    }
    if (enqueued.contains(false)) {
      await _failChapter(task.chapterId, emit, 'Could not start downloads');
    }
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
          _update(
            emit,
            job.chapterId,
            (t) => t.copyWith(progress: job.completed.length / job.totalPages),
          );
        }
      case bd.TaskStatus.failed:
      case bd.TaskStatus.notFound:
      case bd.TaskStatus.canceled:
        // canceled with a live job means the OS killed the task — user
        // cancels remove the job before native cancellation runs.
        await _failChapter(
          job.chapterId,
          emit,
          update.exception?.description ??
              switch (update.status) {
                bd.TaskStatus.notFound =>
                  'HTTP ${update.responseStatusCode ?? 404}',
                bd.TaskStatus.canceled => 'Stopped by the system',
                _ => 'Download failed',
              },
        );
      case bd.TaskStatus.enqueued:
      case bd.TaskStatus.running:
      case bd.TaskStatus.waitingToRetry:
      case bd.TaskStatus.paused:
        break;
    }
  }

  // These three end a chapter's flight. `job.finish()` MUST run even if the
  // filesystem/native cleanup throws — a pending completer would deadlock the
  // serial drain (`await _jobs.values.first.done`) forever.
  Future<void> _finishChapter(
    _ChapterJob job,
    Emitter<DownloadsState> emit,
  ) async {
    _jobs.remove(job.chapterId);
    try {
      await _service.markDone(job.mangaId, job.chapterId);
      await _deleteRecords(job.taskIds);
      _update(
        emit,
        job.chapterId,
        (t) => t.copyWith(status: DownloadTaskStatus.completed, progress: 1),
      );
      emit(state.copyWith(downloaded: {...state.downloaded, job.chapterId}));
    } finally {
      job.finish();
    }
  }

  Future<void> _failChapter(
    int chapterId,
    Emitter<DownloadsState> emit, [
    String? error,
  ]) async {
    final job = _jobs.remove(chapterId);
    try {
      if (job != null) {
        await bd.FileDownloader().cancelAll(
          group: _group(job.mangaId, chapterId),
        );
        await _deleteRecords(job.taskIds);
        // Failed downloads never keep partial pages on disk.
        await _service.delete(job.mangaId, chapterId);
      }
      _update(
        emit,
        chapterId,
        (t) => t.copyWith(status: DownloadTaskStatus.failed, error: error),
      );
    } finally {
      job?.finish();
    }
  }

  /// Cancels a chapter's native tasks, forgets its job and removes partials.
  Future<void> _abortNative(int chapterId) async {
    final job = _jobs.remove(chapterId);
    if (job == null) return;
    try {
      await bd.FileDownloader().cancelAll(
        group: _group(job.mangaId, chapterId),
      );
      await _deleteRecords(job.taskIds);
      await _service.delete(job.mangaId, chapterId);
    } finally {
      job.finish();
    }
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
    emit(
      state.copyWith(
        queue: state.queue
            .map((t) => t.chapterId == chapterId ? fn(t) : t)
            .toList(),
      ),
    );
  }

  /// Persists queue identity/order (not per-page progress) and the paused
  /// flag whenever they change — Mihon's DownloadStore behavior.
  @override
  void onChange(Change<DownloadsState> change) {
    super.onChange(change);
    List<int> activeIds(DownloadsState s) => [
      for (final t in s.queue.where((t) => t.isActive)) t.chapterId,
    ];
    if (!listEquals(
      activeIds(change.currentState),
      activeIds(change.nextState),
    )) {
      _store.save(change.nextState.queue);
    }
    if (change.currentState.paused != change.nextState.paused) {
      _store.setPaused(change.nextState.paused);
    }
    _syncLiveActivity(change.nextState);
  }

  /// Mirrors the queue into the iOS Live Activity (Dynamic Island): one
  /// activity for the whole session, updated per page completion, ended when
  /// nothing is downloading. Single hook — every queue/progress change flows
  /// through an emit. Fire-and-forget; the service dedupes and throttles.
  void _syncLiveActivity(DownloadsState s) {
    final active = s.queue
        .where((t) => t.status == DownloadTaskStatus.downloading)
        .firstOrNull;
    if (active == null || s.paused) {
      // Paused or user-cancelled → dismiss immediately; a naturally drained
      // queue lingers a few seconds showing the finished state.
      final drained =
          !s.paused &&
          s.queue.every((t) => t.status != DownloadTaskStatus.queued);
      _liveActivity.end(immediate: !drained);
      return;
    }
    final job = _jobs[active.chapterId];
    final total = job?.totalPages ?? 0;
    final redact = _securityPrefs.hideNotificationContent;
    _liveActivity.update(
      mangaTitle: redact ? 'Downloading' : active.mangaTitle,
      chapterName: redact ? '' : active.chapterName,
      progress: active.progress.clamp(0, 1),
      completedPages:
          job?.completed.length ?? (active.progress * total).round(),
      totalPages: total,
      queued: s.queue
          .where((t) => t.status == DownloadTaskStatus.queued)
          .length,
    );
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
  }) : taskIds = taskIds ?? {},
       completed = completed ?? {};

  final int mangaId;
  final int chapterId;
  final int totalPages;
  final Set<String> taskIds;

  /// Task ids of completed pages — a set so replayed updates stay idempotent.
  final Set<String> completed;

  /// Resolves when the chapter leaves flight (finished, failed or aborted) —
  /// the serial drain loop waits on this before starting the next chapter.
  final Completer<void> _done = Completer<void>();

  Future<void> get done => _done.future;

  void finish() {
    if (!_done.isCompleted) _done.complete();
  }
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
