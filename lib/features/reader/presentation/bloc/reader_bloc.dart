import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/config/app_settings.dart';
import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/data/source/http_source_base.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_page.dart';
import 'package:mihonx/features/browse/domain/source/model/s_chapter.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/downloads/domain/download_service.dart';
import 'package:mihonx/features/history/domain/history_repository.dart';
import 'package:mihonx/features/manga/domain/manga_repository.dart';
import 'package:mihonx/features/reader/domain/reader_preferences.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_event.dart';
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
    on<ReaderPageChanged>(_onPageChanged);
    on<ReaderOverlayToggled>(
      (e, emit) => emit(state.copyWith(showOverlay: !state.showOverlay)),
    );
    on<ReaderModeChanged>(_onModeChanged);
    on<ReaderNextChapter>((e, emit) => _navigate(1, emit));
    on<ReaderPrevChapter>((e, emit) => _navigate(-1, emit));
  }

  final MangaRepository _repo;
  final SourceManager _sources;
  final HistoryRepository _history;
  final DownloadService _downloads;
  final AppSettings _settings;
  final ReaderPreferences _prefs;

  int _chapterId;
  List<ChapterData> _siblings = const [];
  int _index = -1;
  int? _markedReadChapterId;

  Future<void> _load(int chapterId, Emitter<ReaderState> emit) async {
    emit(state.copyWith(status: const BlocStatus.loading()));
    try {
      final chapter = await _repo.getChapter(chapterId);
      final manga = chapter == null ? null : await _repo.getManga(chapter.mangaId);
      final source = manga == null ? null : _sources.get(manga.source);
      // Downloaded chapters read fully offline; a source is only required
      // when no local pages exist.
      final local = chapter == null
          ? null
          : await _downloads.localPages(chapter.mangaId, chapterId);
      if (chapter == null || (local == null && source == null)) {
        emit(state.copyWith(
          status: const BlocStatus.failure(
            AppException(message: 'Chapter unavailable'),
          ),
        ));
        return;
      }
      _chapterId = chapterId;
      final pages = local != null
          ? List.generate(
              local.length, (i) => MangaPage(index: i, imageUrl: local[i]))
          : await source!.getPageList(
              SChapter(url: chapter.url, name: chapter.name),
            );
      _siblings = await _repo.getChaptersForManga(chapter.mangaId);
      _index = _siblings.indexWhere((c) => c.id == chapterId);
      emit(state.copyWith(
        status: pages.isEmpty
            ? const BlocStatus.empty()
            : const BlocStatus.success(),
        pages: pages,
        currentPage:
            pages.isEmpty ? 0 : chapter.lastPageRead.clamp(0, pages.length - 1),
        chapterId: chapterId,
        chapterName: chapter.name,
        mangaId: chapter.mangaId,
        imageHeaders:
            source is HttpSourceBase ? source.imageHeaders : const {},
        hasPrev: _index > 0,
        hasNext: _index >= 0 && _index < _siblings.length - 1,
      ));
      // Incognito reading leaves no history trail.
      if (!_settings.incognito) await _history.upsert(chapterId);
    } catch (e, st) {
      emit(state.copyWith(status: BlocStatus.failure(AppException.from(e, st))));
    }
  }

  Future<void> _onPageChanged(
    ReaderPageChanged event,
    Emitter<ReaderState> emit,
  ) async {
    // Only touch the database when the page actually changed.
    if (event.page != state.currentPage) {
      emit(state.copyWith(currentPage: event.page));
      await _repo.setLastPageRead(_chapterId, event.page);
    }
    if (state.pages.isNotEmpty &&
        event.page >= state.pages.length - 1 &&
        _markedReadChapterId != _chapterId) {
      _markedReadChapterId = _chapterId;
      await _repo.setChapterRead(_chapterId, true);
    }
  }

  Future<void> _onModeChanged(
    ReaderModeChanged event,
    Emitter<ReaderState> emit,
  ) async {
    await _prefs.setReadingMode(event.mode);
    emit(state.copyWith(readingMode: event.mode));
  }

  Future<void> _navigate(int delta, Emitter<ReaderState> emit) async {
    final target = _index + delta;
    if (target < 0 || target >= _siblings.length) return;
    await _load(_siblings[target].id, emit);
  }
}
