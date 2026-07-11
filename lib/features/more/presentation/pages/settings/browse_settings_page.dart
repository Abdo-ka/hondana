import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/features/browse/domain/source_preferences.dart';
import 'package:mihonx/features/more/presentation/widgets/settings_widgets.dart';

/// Settings > Browse (Mihon's SettingsBrowseScreen, minus the deferred
/// extension-repo manager).
@RoutePage()
class BrowseSettingsPage extends StatelessWidget {
  const BrowseSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => PageLayoutBuilder(
        mobile: (context) => const AppScaffold(
          appBar: AppAppBar(title: 'settings.browse'),
          body: _BrowseSettingsList(),
        ),
      );
}

class _BrowseSettingsList extends StatelessWidget {
  const _BrowseSettingsList();

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<SourcePreferences>();
    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) => ListView(
        children: [
          SwitchListTile(
            value: prefs.hideInLibrary,
            onChanged: prefs.setHideInLibrary,
            title: const AppText.bodyLarge('settings.browse_hide_in_library'),
          ),
          const SettingsSectionHeader('settings.browse_nsfw_header'),
          SwitchListTile(
            value: prefs.showNsfwSources,
            onChanged: prefs.setShowNsfwSources,
            title: const AppText.bodyLarge('settings.browse_show_nsfw'),
            subtitle: AppText.bodySmall(
              'settings.browse_show_nsfw_hint',
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
