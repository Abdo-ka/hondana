import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/config/advanced_preferences.dart';
import 'package:hondana/core/core.dart';
import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/network/app_http.dart';
import 'package:hondana/features/browse/data/source/http_source_base.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/features/downloads/domain/download_service.dart';
import 'package:hondana/features/more/data/maintenance_service.dart';
import 'package:hondana/features/more/presentation/widgets/settings_widgets.dart';

/// Settings > Advanced (Mihon SettingsAdvancedScreen parity where portable):
/// networking overrides, database/cookie/WebView housekeeping, library
/// metadata maintenance.
@RoutePage()
class AdvancedSettingsPage extends StatelessWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PageLayoutBuilder(mobile: (context) => const _AdvancedSettingsView());
}

class _AdvancedSettingsView extends StatefulWidget {
  const _AdvancedSettingsView();

  @override
  State<_AdvancedSettingsView> createState() => _AdvancedSettingsViewState();
}

class _AdvancedSettingsViewState extends State<_AdvancedSettingsView> {
  final AdvancedPreferences _advanced = getIt<AdvancedPreferences>();
  final MaintenanceService _maintenance = MaintenanceService(
    downloads: getIt<DownloadService>(),
    db: getIt<AppDatabase>(),
    cookies: getIt<WebCookieStore>(),
    sources: getIt<SourceManager>(),
    advanced: getIt<AdvancedPreferences>(),
  );

  late final ValueNotifier<String?> _userAgent = ValueNotifier(
    _advanced.userAgent,
  );
  late final ValueNotifier<bool> _updateTitles = ValueNotifier(
    _advanced.updateTitlesFromSource,
  );
  // Long-running maintenance (cover refresh) must not be double-fired.
  final ValueNotifier<bool> _busy = ValueNotifier(false);

  @override
  void dispose() {
    _userAgent.dispose();
    _updateTitles.dispose();
    _busy.dispose();
    super.dispose();
  }

  /// Shows a transient [SnackBar]; [message] is already translated by callers.
  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Prompts for a custom User-Agent. Empty result resets to the built-in
  /// default ([HttpSourceBase.userAgent]); a null result (Cancel) is a no-op.
  Future<void> _editUserAgent() async {
    final controller = TextEditingController(
      text: _userAgent.value ?? HttpSourceBase.userAgent,
    );
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText.titleMedium('settings.user_agent'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            helperText: 'settings.restart_required'.tr(),
          ),
        ),
        actions: [
          // Reset clears the override back to the built-in default.
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: const AppText.bodyMedium('common.reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const AppText.bodyMedium('common.cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const AppText.bodyMedium('common.save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    final trimmed = result.trim();
    await _advanced.setUserAgent(trimmed.isEmpty ? null : trimmed);
    _userAgent.value = _advanced.userAgent;
  }

  /// Confirms then purges non-library manga rows, reporting the deleted count.
  Future<void> _confirmClearDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText.titleMedium('settings.clear_database'),
        content: const AppText.bodyMedium('settings.clear_database_confirm'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const AppText.bodyMedium('common.cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const AppText.bodyMedium('common.ok'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await _maintenance.clearDatabase();
    if (!mounted) return;
    _toast('settings.entries_deleted'.tr(args: ['$deleted']));
  }

  /// Re-fetches all library covers; guarded by [_busy] so it can't double-fire.
  Future<void> _refreshCovers() async {
    if (_busy.value) return;
    _busy.value = true;
    _toast('settings.refresh_covers_started'.tr());
    try {
      final updated = await _maintenance.refreshLibraryCovers();
      if (mounted) _toast('settings.entries_refreshed'.tr(args: ['$updated']));
    } finally {
      _busy.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'settings.advanced'),
      body: ListView(
        children: [
          const SettingsSectionHeader('settings.section_networking'),
          ValueListenableBuilder<String?>(
            valueListenable: _userAgent,
            builder: (context, ua, _) => ListTile(
              title: const AppText.bodyLarge('settings.user_agent'),
              subtitle: AppText.bodySmall(
                ua ?? HttpSourceBase.userAgent,
                color: context.colorScheme.onSurfaceVariant,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: _editUserAgent,
            ),
          ),
          ListTile(
            title: const AppText.bodyLarge('settings.clear_cookies'),
            onTap: () async {
              await _maintenance.clearCookies();
              if (context.mounted) _toast('settings.cookies_cleared'.tr());
            },
          ),
          ListTile(
            title: const AppText.bodyLarge('settings.clear_webview_data'),
            onTap: () async {
              await _maintenance.clearWebViewData();
              if (context.mounted) {
                _toast('settings.webview_data_cleared'.tr());
              }
            },
          ),
          const SettingsSectionHeader('settings.section_data'),
          ListTile(
            title: const AppText.bodyLarge('settings.clear_database'),
            subtitle: AppText.bodySmall(
              'settings.clear_database_hint',
              color: context.colorScheme.onSurfaceVariant,
            ),
            onTap: _confirmClearDatabase,
          ),
          const SettingsSectionHeader('settings.library'),
          ValueListenableBuilder<bool>(
            valueListenable: _busy,
            builder: (context, busy, _) => ListTile(
              enabled: !busy,
              title: const AppText.bodyLarge('settings.refresh_covers'),
              trailing: busy
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                      ),
                    )
                  : null,
              onTap: _refreshCovers,
            ),
          ),
          ListTile(
            title: const AppText.bodyLarge('settings.reset_viewer_flags'),
            onTap: () async {
              final count = await _maintenance.resetViewerFlags();
              if (context.mounted) {
                _toast('settings.entries_updated'.tr(args: ['$count']));
              }
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _updateTitles,
            builder: (context, value, _) => SwitchListTile(
              value: value,
              onChanged: (v) {
                _updateTitles.value = v;
                _advanced.setUpdateTitlesFromSource(v);
              },
              title: const AppText.bodyLarge('settings.update_titles'),
              subtitle: AppText.bodySmall(
                'settings.update_titles_hint',
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
