import 'package:auto_route/auto_route.dart';

import 'package:mihonx/core/routing/app_router.gr.dart';

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
      ];
}
