import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';
import 'package:mihonx/features/browse/domain/source/source.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/manga/domain/manga_repository.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_event.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_state.dart';

@injectable
class MangaDetailsBloc extends Bloc<MangaDetailsEvent, MangaDetailsState> {
  MangaDetailsBloc(
    this._repo,
    this._sources,
    @factoryParam this.sourceId,
    @factoryParam this.initial,
  ) : super(MangaDetailsState(source: initial)) {
    on<MangaDetailsStarted>(_onStart);
    on<MangaWatchRequested>(_onWatchManga, transformer: restartable());
    on<ChaptersWatchRequested>(_onWatchChapters, transformer: restartable());
    on<MangaFavoriteToggled>(_onFavorite);
    on<MangaChapterReadToggled>(_onChapterRead);
    on<MangaChaptersRefreshed>(_onRefresh, transformer: droppable());
    on<MangaChapterSortToggled>(
      (e, emit) => emit(state.copyWith(
        chapters: state.chapters.reversed.toList(),
        chaptersDescending: !state.chaptersDescending,
      )),
    );
  }

  final MangaRepository _repo;
  final SourceManager _sources;
  final int sourceId;
  final SManga initial;

  Source? get _source => _sources.get(sourceId);

  Future<void> _onStart(
    MangaDetailsStarted event,
    Emitter<MangaDetailsState> emit,
  ) async {
    final id = await _repo.resolveManga(sourceId, initial);
    emit(state.copyWith(
      mangaId: id,
      detailsStatus: const BlocStatus.loading(),
      chaptersStatus: const BlocStatus.loading(),
    ));
    add(MangaWatchRequested(id));
    add(ChaptersWatchRequested(id));

    final source = _source;
    if (source == null) {
      emit(state.copyWith(
        detailsStatus: const BlocStatus.failure(
          AppException(message: 'Source unavailable'),
        ),
      ));
      return;
    }

    try {
      final details = await source.getMangaDetails(initial);
      await _repo.updateDetails(id, details);
      emit(state.copyWith(detailsStatus: const BlocStatus.success()));
    } catch (e, st) {
      emit(state.copyWith(
        detailsStatus: BlocStatus.failure(AppException.from(e, st)),
      ));
    }

    await _fetchChapters(id, source, emit);
  }

  Future<void> _onWatchManga(
    MangaWatchRequested event,
    Emitter<MangaDetailsState> emit,
  ) {
    return emit.forEach(
      _repo.watchManga(event.mangaId),
      onData: (manga) => state.copyWith(manga: manga),
    );
  }

  Future<void> _onWatchChapters(
    ChaptersWatchRequested event,
    Emitter<MangaDetailsState> emit,
  ) {
    return emit.forEach(
      _repo.watchChapters(event.mangaId),
      onData: (chapters) => state.copyWith(chapters: chapters),
    );
  }

  Future<void> _fetchChapters(
    int id,
    Source source,
    Emitter<MangaDetailsState> emit,
  ) async {
    try {
      final chapters = await source.getChapterList(initial);
      await _repo.syncChapters(id, chapters);
      emit(state.copyWith(
        chaptersStatus: chapters.isEmpty
            ? const BlocStatus.empty()
            : const BlocStatus.success(),
      ));
    } catch (e, st) {
      emit(state.copyWith(
        chaptersStatus: BlocStatus.failure(AppException.from(e, st)),
      ));
    }
  }

  Future<void> _onFavorite(
    MangaFavoriteToggled event,
    Emitter<MangaDetailsState> emit,
  ) async {
    final id = state.mangaId;
    if (id == null) return;
    await _repo.setFavorite(id, !state.isFavorite);
  }

  Future<void> _onChapterRead(
    MangaChapterReadToggled event,
    Emitter<MangaDetailsState> emit,
  ) async {
    await _repo.setChapterRead(event.chapterId, event.read);
  }

  Future<void> _onRefresh(
    MangaChaptersRefreshed event,
    Emitter<MangaDetailsState> emit,
  ) async {
    final id = state.mangaId;
    final source = _source;
    if (id == null || source == null) return;
    emit(state.copyWith(chaptersStatus: const BlocStatus.loading()));
    await _fetchChapters(id, source, emit);
  }
}
