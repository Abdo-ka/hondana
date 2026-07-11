import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';
import 'package:mihonx/features/downloads/domain/download_queue_store.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_state.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_state.dart';

ChapterData _chapter(int id, {bool read = false}) => ChapterData(
      id: id,
      mangaId: 1,
      url: '/c$id',
      name: 'Chapter $id',
      read: read,
      bookmark: false,
      lastPageRead: 0,
      chapterNumber: id.toDouble(),
      sourceOrder: 0,
    );

void main() {
  test('queue store round-trips active tasks in order, drops finished', () async {
    SharedPreferences.setMockInitialValues({});
    final store = DownloadQueueStore(await SharedPreferences.getInstance());
    await store.save(const [
      DownloadTask(chapterId: 1, mangaId: 9, mangaTitle: 'M', chapterName: 'c1'),
      DownloadTask(
        chapterId: 2,
        mangaId: 9,
        mangaTitle: 'M',
        chapterName: 'c2',
        status: DownloadTaskStatus.downloading,
      ),
      DownloadTask(
        chapterId: 3,
        mangaId: 9,
        mangaTitle: 'M',
        chapterName: 'c3',
        status: DownloadTaskStatus.completed,
      ),
    ]);
    final restored = store.load();
    // Order preserved, completed dropped, downloading collapses to queued.
    expect(restored.map((t) => t.chapterId), [1, 2]);
    expect(restored.every((t) => t.status == DownloadTaskStatus.queued), isTrue);

    await store.setPaused(true);
    expect(store.paused, isTrue);
  });

  test('details ordering helpers: canonical newest-first list', () {
    // Canonical order as streamed from the repo: newest first (ch3, ch2, ch1).
    final state = MangaDetailsState(
      source: const SManga(url: '/m', title: 'M'),
      chapters: [
        _chapter(3),
        _chapter(2, read: true),
        _chapter(1, read: true),
      ],
    );
    // Downloads must queue chapter 1 first.
    expect(state.ascendingChapters.map((c) => c.id), [1, 2, 3]);
    expect(state.unreadAscending.map((c) => c.id), [3]);
    // Start reading targets the earliest unread.
    expect(state.nextUnread?.id, 3);
    // Default display: newest at top; toggle handled via orderedChapters.
    expect(state.orderedChapters.first.id, 3);
    expect(
      state.copyWith(chaptersDescending: false).orderedChapters.first.id,
      1,
    );
  });
}
