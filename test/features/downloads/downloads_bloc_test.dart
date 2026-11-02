import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/features/browse/domain/source/model/manga_page.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';
import 'package:hondana/features/browse/domain/source/source.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/features/downloads/domain/download_preferences.dart';
import 'package:hondana/features/downloads/domain/download_queue_store.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_state.dart';
import 'package:hondana/features/manga/domain/repositories/manga_repository.dart';
import 'package:hondana/features/more/domain/security_preferences.dart';
import 'package:hondana/services/download_service.dart';
import 'package:hondana/services/live_activity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final storage = _Storage();
  late Directory directory;
  late DownloadsBloc bloc;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('download-queue-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.bbflight.background_downloader'),
          (call) async {
            return switch (call.method) {
              'permissionStatus' => bd.PermissionStatus.granted.index,
              'allTasks' => <String>[],
              'popStatusUpdates' ||
              'popProgressUpdates' ||
              'popResumeData' => '{}',
              'cancelTasksWithIds' => true,
              'enqueue' => true,
              _ => null,
            };
          },
        );
    await bd.FileDownloader(persistentStorage: storage).ready;
  });

  tearDownAll(() => directory.delete(recursive: true));

  test(
    'next chapters are prepared ahead and files reconcile on resume',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final source = _Source('${directory.path}/source.png');
      await File(source.path).writeAsBytes([1, 2, 3]);
      final service = _Downloads(directory);
      bloc = DownloadsBloc(
        service,
        _Repository(),
        _Sources(source),
        DownloadQueueStore(prefs),
        DownloadPreferences(prefs),
        SecurityPreferences(prefs),
        LiveActivityService(),
      );
      for (final id in [1, 2]) {
        bloc.add(
          DownloadEnqueued(
            chapterId: id,
            mangaId: 1,
            mangaTitle: 'Manga',
            chapterName: '$id',
          ),
        );
      }
      // Chapter 1's remote pages are handed to the native downloader, which
      // never reports back here. Chapter 2 must still be prepared meanwhile —
      // the lookahead that keeps the queue moving while Dart is suspended in
      // the background.
      await _waitUntil(
        () => bloc.state.downloaded.contains(2),
        'second chapter prepared ahead',
      );
      expect(source.requested, ['1', '2']);
      expect(bloc.state.taskFor(1)?.status, DownloadTaskStatus.downloading);
      expect(await service.isDownloaded(1, 1), isFalse);
      expect((await service.localPages(1, 2))!.single, endsWith('p0001.png'));
      expect(await service.localPages(1, 99), isNull);

      final scans = storage.scans;
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await _waitUntil(() => storage.scans > scans, 'resume scan');
      await bloc.close();
    },
  );
}

Future<void> _waitUntil(bool Function() predicate, String reason) async {
  for (var i = 0; i < 200 && !predicate(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(predicate(), isTrue, reason: reason);
}

class _Storage implements bd.PersistentStorage {
  int scans = 0;
  @override
  Future<void> initialize() async {}
  @override
  Future<List<bd.TaskRecord>> retrieveAllTaskRecords() async {
    scans++;
    return [];
  }

  @override
  Future<List<bd.Task>> retrieveAllPausedTasks() async => [];
  @override
  Future<void> removeTaskRecord(String? taskId) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Downloads extends DownloadService {
  _Downloads(this.directory);
  final Directory directory;
  @override
  Future<Directory> root() async => directory;
}

class _Source implements Source {
  _Source(this.path);
  final String path;
  final requested = <String>[];
  @override
  Future<List<MangaPage>> getPageList(SChapter chapter) async {
    requested.add(chapter.url);
    // Chapter 1 is remote (native task), every other chapter is local.
    return [
      MangaPage(
        index: 0,
        imageUrl: chapter.url == '1' ? 'https://example.com/p1.png' : path,
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sources implements SourceManager {
  _Sources(this.source);
  final Source source;
  @override
  Source? get(int id) => source;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repository implements MangaRepository {
  @override
  Future<ChapterData?> getChapter(int chapterId) async => ChapterData(
    id: chapterId,
    mangaId: 1,
    url: '$chapterId',
    name: '$chapterId',
    read: false,
    bookmark: false,
    lastPageRead: 0,
    chapterNumber: chapterId.toDouble(),
    sourceOrder: chapterId,
  );
  @override
  Future<MangaData?> getManga(int mangaId) async => const MangaData(
    id: 1,
    source: 1,
    url: 'manga',
    title: 'Manga',
    status: 0,
    favorite: true,
    viewerFlags: 0,
    chapterFlags: 0,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
