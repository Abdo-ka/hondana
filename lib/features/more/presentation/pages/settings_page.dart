import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/routing/app_router.gr.dart';

/// Settings main menu — Mihon's SettingsMainScreen order, minus the deferred
/// Tracking entry. Every row pushes its dedicated settings screen.
@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => PageLayoutBuilder(
        mobile: (context) => AppScaffold(
          appBar: const AppAppBar(title: 'settings.title'),
          body: ListView(
            children: const [
              _SettingsMenuTile(
                icon: Icons.palette_outlined,
                titleKey: 'settings.appearance',
                route: AppearanceSettingsRoute(),
              ),
              _SettingsMenuTile(
                icon: Icons.collections_bookmark_outlined,
                titleKey: 'settings.library',
                route: LibrarySettingsRoute(),
              ),
              _SettingsMenuTile(
                icon: Icons.chrome_reader_mode_outlined,
                titleKey: 'settings.reader',
                route: ReaderSettingsRoute(),
              ),
              _SettingsMenuTile(
                icon: Icons.download_outlined,
                titleKey: 'settings.downloads',
                route: DownloadsSettingsRoute(),
              ),
              _SettingsMenuTile(
                icon: Icons.explore_outlined,
                titleKey: 'settings.browse',
                route: BrowseSettingsRoute(),
              ),
              _SettingsMenuTile(
                icon: Icons.storage_outlined,
                titleKey: 'settings.data_storage',
                route: DataStorageSettingsRoute(),
              ),
              _SettingsMenuTile(
                icon: Icons.security_outlined,
                titleKey: 'settings.security',
                route: SecuritySettingsRoute(),
              ),
              _SettingsMenuTile(
                icon: Icons.code_outlined,
                titleKey: 'settings.advanced',
                route: AdvancedSettingsRoute(),
              ),
              _SettingsMenuTile(
                icon: Icons.info_outline,
                titleKey: 'settings.about',
                route: AboutRoute(),
              ),
            ],
          ),
        ),
      );
}

class _SettingsMenuTile extends StatelessWidget {
  const _SettingsMenuTile({
    required this.icon,
    required this.titleKey,
    required this.route,
  });

  final IconData icon;
  final String titleKey;
  final PageRouteInfo route;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: context.colorScheme.primary),
        title: AppText.bodyLarge(titleKey),
        onTap: () => context.router.push(route),
      );
}
