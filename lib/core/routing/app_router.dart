import 'package:auto_route/auto_route.dart';

import 'package:hondana/core/routing/app_router.gr.dart';

/// Root router. Tabs live under [MainRoute] as an AutoTabs shell. Feature detail
/// routes (manga, reader, settings, …) are added as top-level routes as they land.
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainRoute.page,
      initial: true,
      path: '/',
      children: [
        AutoRoute(page: LibraryRoute.page, initial: true, path: 'library'),
        AutoRoute(page: UpdatesRoute.page, path: 'updates'),
        AutoRoute(page: HistoryRoute.page, path: 'history'),
        AutoRoute(page: BrowseRoute.page, path: 'browse'),
        AutoRoute(page: MoreRoute.page, path: 'more'),
      ],
    ),
    AutoRoute(page: SourceCatalogueRoute.page, path: '/catalogue'),
    AutoRoute(page: MangaDetailsRoute.page, path: '/manga'),
    AutoRoute(page: ExtensionsRoute.page, path: '/extensions'),
    AutoRoute(page: GlobalSearchRoute.page, path: '/search'),
    AutoRoute(page: ReaderRoute.page, path: '/reader'),
    AutoRoute(page: DownloadsRoute.page, path: '/downloads'),
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
    AutoRoute(page: AppearanceSettingsRoute.page, path: '/settings/appearance'),
    AutoRoute(page: LibrarySettingsRoute.page, path: '/settings/library'),
    AutoRoute(page: ReaderSettingsRoute.page, path: '/settings/reader'),
    AutoRoute(page: DownloadsSettingsRoute.page, path: '/settings/downloads'),
    AutoRoute(page: BrowseSettingsRoute.page, path: '/settings/browse'),
    AutoRoute(page: DataStorageSettingsRoute.page, path: '/settings/data'),
    AutoRoute(page: SecuritySettingsRoute.page, path: '/settings/security'),
    AutoRoute(page: AdvancedSettingsRoute.page, path: '/settings/advanced'),
    AutoRoute(page: AboutRoute.page, path: '/about'),
    AutoRoute(page: CategoriesRoute.page, path: '/categories'),
    AutoRoute(page: SourceWebViewRoute.page, path: '/webview'),
  ];
}
