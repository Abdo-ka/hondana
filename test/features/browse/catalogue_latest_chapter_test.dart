import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hondana/features/browse/data/source/madara/madara_sites.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/browse/domain/source/source.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/features/browse/domain/source_preferences.dart';
import 'package:hondana/features/browse/presentation/bloc/global_search_bloc.dart';
import 'package:hondana/features/browse/presentation/bloc/global_search_event.dart';
import 'package:hondana/features/browse/presentation/bloc/source_catalogue_bloc.dart';
import 'package:hondana/features/browse/presentation/bloc/source_catalogue_event.dart';
import 'package:hondana/features/browse/presentation/widgets/source_manga_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Representative Madara archive/search markup: latest chapter links share
// the same response as the cover/title and rating.
const _listing = '''
<div class="page-item-detail">
 <div class="post-title"><a href="/manga/spy-family/">SPY×FAMILY</a></div>
 <span class="score">4.3</span>
 <div class="list-chapter">
  <div class="chapter-item"><span class="chapter"><a href="/manga/spy-family/141-1/">141.1</a></span></div>
  <div class="chapter-item"><span class="chapter"><a href="/manga/spy-family/140/">140</a></span></div>
 </div>
</div>
<div class="page-item-detail">
 <div class="post-title"><a href="/manga/cosmic-3077/">Cosmic 3077</a></div>
 <span class="score">4.4</span>
</div>
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => GetIt.instance.reset());

  test(
    'listing keeps newest decimal chapter and never counts preview links',
    () {
      final manga = ManhuausSource().parsePopular(_listing);
      expect(manga.first.latestChapter, '141.1');
      expect(manga.first.copyWith(title: 'Updated').latestChapter, '141.1');
      expect(manga.last.latestChapter, isNull);
    },
  );

  test('search cards retain localized and special chapter labels', () {
    final source = ManhuausSource();
    final manga = source.parsePopular('''
<div class="c-tabs-item__content">
 <div class="post-title"><a href="/manga/title/">Title</a></div>
 <div class="latest-chap"><a href="/manga/title/extra/">  الفصل ١٢٫٥  </a></div>
</div>
''');
    expect(manga.single.latestChapter, 'الفصل ١٢٫٥');
  });

  for (final source in madaraSources().where(
    (s) => s.name.trim() == 'mangalek' || s.name == 'mangalink',
  )) {
    test(
      '${source.name.trim()}: one listing request per page, no chapter requests',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = SourcePreferences(await SharedPreferences.getInstance());
        GetIt.instance.registerSingleton(prefs);
        final requests = <RequestOptions>[];
        source.client.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests.add(options);
              handler.resolve(
                Response(requestOptions: options, data: _listing),
              );
            },
          ),
        );
        final manager = _Sources(source);
        final bloc = SourceCatalogueBloc(manager, source.id);
        final listed = bloc.stream.firstWhere((s) => s.loadStatus.isSuccess());
        bloc.add(const CatalogueSearched('spy'));
        expect((await listed).manga.first.latestChapter, '141.1');
        await Future<void>.delayed(Duration.zero);
        expect(requests.length, 1);
        final next = bloc.stream.firstWhere((s) => s.page == 2);
        bloc.add(const CatalogueLoadMore());
        expect((await next).manga.last.latestChapter, isNull);
        await bloc.close();
        expect(requests.length, 2);

        final global = GlobalSearchBloc(manager, prefs);
        final found = global.stream.firstWhere(
          (s) => s.results.single.status.isSuccess(),
        );
        global.add(const GlobalSearched('spy'));
        expect((await found).results.single.manga.first.latestChapter, '141.1');
        await global.close();
        expect(requests.length, 3);
        expect(
          requests.map((r) => r.uri.path),
          everyElement('/wp-admin/admin-ajax.php'),
        );
        expect(
          requests.map((r) => (r.data as Map)['action']),
          everyElement('madara_load_more'),
        );
      },
    );
  }

  testWidgets(
    'latest badge fits a three-column grid and hides missing labels',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await EasyLocalization.ensureInitialized();
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const _GridHarness());
      await tester.pumpAndSettle();
      expect(find.text('Latest: 141.1'), findsOneWidget);
      expect(find.text('Known title'), findsOneWidget);
      expect(find.text('Unknown title'), findsOneWidget);
      expect(find.textContaining('chapters'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

class _Sources implements SourceManager {
  _Sources(this.source);
  final CatalogueSource source;

  @override
  Source? get(int id) => source;
  @override
  CatalogueSource? getCatalogueSource(int id) => source;
  @override
  List<Source> getSources() => [source];
  @override
  List<CatalogueSource> getCatalogueSources() => [source];
}

class _Translations extends AssetLoader {
  const _Translations();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => {
    'browse': {'latest_chapter': 'Latest: {chapter}'},
  };
}

class _GridHarness extends StatelessWidget {
  const _GridHarness();

  @override
  Widget build(BuildContext context) => EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const _Translations(),
    child: const _GridPreview(),
  );
}

class _GridPreview extends StatelessWidget {
  const _GridPreview();

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(360, 800),
    builder: (context, child) => MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: Scaffold(
        body: SourceMangaGrid(
          manga: const [
            SManga(
              url: '/known/',
              title: 'Known title',
              latestChapter: '141.1',
            ),
            SManga(url: '/unknown/', title: 'Unknown title'),
          ],
          sourceId: 1,
          hasNext: false,
          onLoadMore: () {},
        ),
      ),
    ),
  );
}
