import 'package:drift/native.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mihonx/app.dart';
import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/routing/app_router.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/data/source/local_source.dart';
import 'package:mihonx/features/browse/data/source/stub_source_manager.dart';
import 'package:mihonx/features/library/data/library_repository_impl.dart';

void main() {
  test('BlocStatus equality treats same status as equal', () {
    expect(const BlocStatus.loading(), const BlocStatus.loading());
    expect(const BlocStatus.success() == const BlocStatus.loading(), isFalse);
    expect(
      const BlocStatus.failure(AppException(message: 'a')),
      const BlocStatus.failure(AppException(message: 'a')),
    );
    expect(
      const BlocStatus.failure(AppException(message: 'a')) ==
          const BlocStatus.failure(AppException(message: 'b')),
      isFalse,
    );
  });

  test('StubSourceManager resolves LocalSource by id', () {
    final manager = StubSourceManager();
    expect(manager.get(LocalSource.localSourceId), isA<LocalSource>());
    expect(manager.getCatalogueSources().length, 1);
    expect(manager.get(999), isNull);
  });

  test('LibraryRepository seeds and streams library with unread counts',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = LibraryRepositoryImpl(db);

    expect(await repo.favoriteCount(), 0);
    await repo.seedDevDataIfEmpty();
    expect(await repo.favoriteCount(), 6);

    final library = await repo.watchLibrary().first;
    expect(library.length, 6);
    // "Solo Leveling" (seed index 0) has 8 chapters, 0 read → 8 unread.
    final solo = library.firstWhere((e) => e.manga.title == 'Solo Leveling');
    expect(solo.unreadCount, 8);

    await db.close();
  });

  testWidgets('app boots to the 5-tab shell', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    LibraryRepositoryImpl.devSeedEnabled = false;
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    if (!getIt.isRegistered<AppRouter>()) {
      await configureDependencies();
    }
    // Use an in-memory DB so the Library tab doesn't hit path_provider.
    if (getIt.isRegistered<AppDatabase>()) {
      await getIt.unregister<AppDatabase>();
    }
    getIt.registerLazySingleton<AppDatabase>(
      () => AppDatabase.forTesting(NativeDatabase.memory()),
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MihonxApp(router: getIt<AppRouter>()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(NavigationBar), findsOneWidget);

    // Tear down the tree so the bloc closes and the drift stream subscription
    // is cancelled (otherwise flutter_test flags a pending timer).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
