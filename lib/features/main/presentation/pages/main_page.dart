import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:hondana/core/routing/app_router.gr.dart';

/// Bottom-nav shell hosting the five primary tabs, mirroring Mihon's navigation.
///
/// Uses [AutoTabsScaffold] so each tab keeps its own nested navigation stack;
/// tab order (Library, Updates, History, Browse, More) matches Mihon.
@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        LibraryRoute(),
        UpdatesRoute(),
        HistoryRoute(),
        BrowseRoute(),
        MoreRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) => NavigationBar(
        selectedIndex: tabsRouter.activeIndex,
        onDestinationSelected: tabsRouter.setActiveIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.collections_bookmark_outlined),
            selectedIcon: const Icon(Icons.collections_bookmark),
            label: 'nav.library'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.new_releases_outlined),
            selectedIcon: const Icon(Icons.new_releases),
            label: 'nav.updates'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: 'nav.history'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore),
            label: 'nav.browse'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: 'nav.more'.tr(),
          ),
        ],
      ),
    );
  }
}
