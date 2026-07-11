import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/config/app_settings.dart';
import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/data/source/http_source_base.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_page.dart';
import 'package:mihonx/features/browse/domain/source/model/s_chapter.dart';
import 'package:mihonx/features/browse/domain/source/source.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/downloads/domain/download_service.dart';
import 'package:mihonx/features/history/domain/history_repository.dart';
import 'package:mihonx/features/manga/domain/manga_repository.dart';
import 'package:mihonx/features/reader/domain/reader_preferences.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_event.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_item.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_state.dart';

@injectable
class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  ReaderBloc(
    this._repo,
    this._sources,
    this._history,
    this._downloads,
    this._settings,
    ReaderPreferences prefs,
    @factoryParam this._chapterId,
  )   : _prefs = prefs,
        super(ReaderState(readingMode: prefs.readingMode)) {
    on<ReaderStarted>((e, emit) => _load(_chapterId, emit));
    // Sequential so a fast fling's backlog of reports cannot interleave at
    // the awaits and write lastPageRead out of order.
    on<ReaderItemChanged>(_onItemChanged, transformer: sequential());
    on<ReaderPageChanged>(_onPageChanged);
    on<ReaderOverlayToggled>(
      (e, emit) => emit(state.copyWith(showOverlay: !state.showOverlay)),
    );
    on<ReaderModeChanged>(_onModeChanged);
    on<ReaderNextChapter>((e, emit) => _navigate(1, emit));
    on<ReaderPrevChapter>((e, emit) => _navigate(-1, emit));
  }

  /// Preload the next chapter once the reader is this close to the end of
  /// the loaded items (Mihon preloads at the chapter transition).
  static const _preloadMargin = 4;

  final MangaRepository _repo;
  final SourceManager _sources;
  final HistoryRepository _history;
  final DownloadService _downloads;
  final AppSettings _settings;
  final ReaderPreferences _prefs;

  int _chapterId;

  /// Reading order: oldest → newest, so +1 is the next chapter.
  List<ChapterData> _siblings = const [];
  int _index = -1;

  /// Index into [_siblings] of the last chapter whose pages are in `items`.
  int _loadedThrough = -1;
  bool _loadingNext = false;
  Source? _source;
  final Set<int> _markedRead = {};

  /// Bumped by every [_load]; an in-flight [_maybeLoadNext] captures it before
  /// its await and bails if it changed, so a preload started for the old
  /// chapter can't append pages onto a freshly-loaded one.
  int _loadGeneration = 0;

  Future<void> _load(int chapterId, Emitter<ReaderState> emit) async {
    final generation = ++_loadGeneration;
    emit(state.copyWith(status: const BlocStatus.loading()));
    try {
      final chapter = await _repo.getChapter(chapterId);
      final manga = chapter == null ? null : await _repo.getManga(chapter.mangaId);
      _source = manga == null ? null : _sources.get(manga.source);
      final pages = chapter == null
          ? null
          : await _pagesFor(chapter);
      if (chapter == null || pages == null) {
        emit(state.copyWith(
          status: const BlocStatus.failure(
            AppException(message: 'Chapter unavailable'),
          ),
        ));
        return;
      }
      // A newer _load (e.g. a second next-tap) superseded this one while its
      // pages were loading — drop this stale result.
      if (generation != _loadGeneration) return;
      _chapterId = chapterId;
      _siblings = await _repo.getChaptersForManga(chapter.mangaId);
      _index = _siblings.indexWhere((c) => c.id == chapterId);
      _loadedThrough = _index;
      _loadingNext = false;
      final items = [
        ..._pageItems(chapter.id, chapter.name, pages),
        ReaderTransitionItem(
          fromChapterId: chapter.id,
          fromChapterName: chapter.name,
          toChapterName: _nameAt(_nextIndexFrom(_index)),
        ),
      ];
      // Per-series mode (Mihon viewer_flags): 0 = app default,
      // else ReadingMode.index + 1.
      final flags = manga?.viewerFlags ?? 0;
      final mode = flags > 0 && flags <= ReadingMode.values.length
          ? ReadingMode.values[flags - 1]
          : _prefs.readingMode;
      final initialPage =
          pages.isEmpty ? 0 : chapter.lastPageRead.clamp(0, pages.length - 1);
      emit(state.copyWith(
        status: pages.isEmpty
            ? const BlocStatus.empty()
            : const BlocStatus.success(),
        items: items,
        readingMode: mode,
        // For the first loaded chapter, item index == page index.
        currentItem: initialPage,
        // A load is an explicit seek: readers must jump to the new position.
        seek: state.seek + 1,
        currentPage: initialPage,
        pageCount: pages.length,
        chapterId: chapterId,
        chapterName: chapter.name,
        mangaId: chapter.mangaId,
        imageHeaders: _source is HttpSourceBase
            ? (_source! as HttpSourceBase).imageHeaders
            : const {},
        hasPrev: _index > 0,
        hasNext: _index >= 0 && _nextIndexFrom(_index) != -1,
      ));
      // Incognito reading leaves no history trail.
      if (!_settings.incognito) await _history.upsert(chapterId);
      // Short chapters can open already within preload range of the end.
      if (state.currentItem + _preloadMargin >= state.items.length) {
        await _maybeLoadNext(emit);
      }
    } catch (e, st) {
      emit(state.copyWith(status: BlocStatus.failure(AppException.from(e, st))));
    }
  }

  /// Downloaded chapters read fully offline; a source is only required when
  /// no local pages exist. Returns null when neither is available.
  Future<List<MangaPage>?> _pagesFor(ChapterData chapter) async {
    final local = await _downloads.localPages(chapter.mangaId, chapter.id);
    if (local != null) {
      return List.generate(
        local.length,
        (i) => MangaPage(index: i, imageUrl: local[i]),
      );
    }
    final source = _source;
    if (source == null) return null;
    return source.getPageList(SChapter(url: chapter.url, name: chapter.name));
  }

  List<ReaderPageItem> _pageItems(
    int chapterId,
    String chapterName,
    List<MangaPage> pages,
  ) =>
      [
        for (var i = 0; i < pages.length; i++)
          ReaderPageItem(
            chapterId: chapterId,
            chapterName: chapterName,
            pageIndex: i,
            pageCount: pages.length,
            page: pages[i],
          ),
      ];

  String? _nameAt(int index) =>
      index >= 0 && index < _siblings.length ? _siblings[index].name : null;

  /// Next sibling index honoring "Skip chapters marked read" and "Skip
  /// duplicate chapters" (forward navigation and preload only — going back
  /// must always work, even through read chapters). Returns -1 when none.
  int _nextIndexFrom(int from) {
    final fromNumber = from >= 0 && from < _siblings.length
        ? _siblings[from].chapterNumber
        : null;
    for (var i = from + 1; i < _siblings.length; i++) {
      final c = _siblings[i];
      if (_prefs.skipRead && c.read) continue;
      if (_prefs.skipDuplicates &&
          fromNumber != null &&
          fromNumber >= 0 &&
          c.chapterNumber == fromNumber) {
        continue;
      }
      return i;
    }
    return -1;
  }

  Future<void> _onItemChanged(
    ReaderItemChanged event,
    Emitter<ReaderState> emit,
  ) async {
    final index = event.index;
    // Stale reports from a widget that hasn't rebuilt after a chapter switch.
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];
    switch (item) {
      case ReaderTransitionItem():
        // Reaching the card means the chapter above it is finished — mark it
        // read (a fast webtoon fling can skip its exact last-page item).
        await _markRead(item.fromChapterId);
        emit(state.copyWith(currentItem: index));
      case ReaderPageItem():
        final newIndex = _siblings.indexWhere((c) => c.id == item.chapterId);
        final switched = item.chapterId != state.chapterId;
        if (switched && newIndex > _index) {
          // Crossed one or more boundaries going forward: every chapter we
          // passed (old _index up to, excluding, the new one) is finished.
          // Handles the webtoon case where the last page / transition were
          // never reported because a fling jumped straight into the next
          // chapter.
          for (var i = _index; i < newIndex; i++) {
            await _markRead(_siblings[i].id);
          }
        }
        if (switched) {
          // This chapter is now the one being read (history, next/prev
          // targets, indicator).
          _chapterId = item.chapterId;
          _index = newIndex;
        }
        emit(state.copyWith(
          currentItem: index,
          currentPage: item.pageIndex,
          pageCount: item.pageCount,
          chapterId: item.chapterId,
          chapterName: item.chapterName,
          hasPrev: _index > 0,
          hasNext: _index >= 0 && _nextIndexFrom(_index) != -1,
        ));
        if (switched && !_settings.incognito) {
          await _history.upsert(item.chapterId);
        }
        await _repo.setLastPageRead(item.chapterId, item.pageIndex);
        if (item.pageIndex >= item.pageCount - 1) {
          await _markRead(item.chapterId);
        }
    }
    if (index + _preloadMargin >= state.items.length) {
      await _maybeLoadNext(emit);
    }
  }

  /// Marks a chapter read once (deduped so replayed reports stay idempotent).
  Future<void> _markRead(int chapterId) async {
    if (_markedRead.add(chapterId)) {
      await _repo.setChapterRead(chapterId, true);
    }
  }

  /// Appends the next chapter's pages plus its trailing transition, so the
  /// reader flows continuously (Mihon's chapter preload). Failures leave the
  /// transition in place; the next scroll retries.
  Future<void> _maybeLoadNext(Emitter<ReaderState> emit) async {
    if (_loadingNext) return;
    final nextIndex = _nextIndexFrom(_loadedThrough);
    if (nextIndex <= 0 || nextIndex >= _siblings.length) return;
    _loadingNext = true;
    final generation = _loadGeneration;
    try {
      final chapter = _siblings[nextIndex];
      final pages = await _pagesFor(chapter);
      // A chapter switch (_load) happened during the fetch — this preload
      // targeted the previous chapter's neighbour; appending it now would
      // duplicate or splice the wrong chapter onto the fresh item list.
      if (generation != _loadGeneration) return;
      if (pages == null || pages.isEmpty) {
        // Nothing to show for this chapter — advance past it so the same empty
        // chapter isn't re-fetched on every subsequent scroll near the end.
        _loadedThrough = nextIndex;
        return;
      }
      _loadedThrough = nextIndex;
      emit(state.copyWith(items: [
        ...state.items,
        ..._pageItems(chapter.id, chapter.name, pages),
        ReaderTransitionItem(
          fromChapterId: chapter.id,
          fromChapterName: chapter.name,
          toChapterName: _nameAt(_nextIndexFrom(nextIndex)),
        ),
      ]));
    } on Exception {
      // Keep the transition; a later scroll near the end retries the load.
    } finally {
      _loadingNext = false;
    }
  }

  /// Slider seek — chapter-relative page to global item index.
  Future<void> _onPageChanged(
    ReaderPageChanged event,
    Emitter<ReaderState> emit,
  ) async {
    if (event.page == state.currentPage) return;
    final index = state.items.indexWhere(
      (item) =>
          item is ReaderPageItem &&
          item.chapterId == state.chapterId &&
          item.pageIndex == event.page,
    );
    if (index == -1) return;
    await _onItemChanged(ReaderItemChanged(index), emit);
    // Slider moves are explicit seeks; scroll-report echoes never bump this.
    emit(state.copyWith(seek: state.seek + 1));
  }

  /// In-reader mode selector is per-series (Mihon viewer_flags); the global
  /// default only changes from Settings > Reader.
  Future<void> _onModeChanged(
    ReaderModeChanged event,
    Emitter<ReaderState> emit,
  ) async {
    final mangaId = state.mangaId;
    if (mangaId != null) {
      final mode = event.mode;
      await _repo.setViewerFlags(mangaId, mode == null ? 0 : mode.index + 1);
    }
    emit(state.copyWith(readingMode: event.mode ?? _prefs.readingMode));
  }

  Future<void> _navigate(int delta, Emitter<ReaderState> emit) async {
    final target = delta > 0 ? _nextIndexFrom(_index) : _index - 1;
    if (target < 0 || target >= _siblings.length) return;
    await _load(_siblings[target].id, emit);
  }
}
