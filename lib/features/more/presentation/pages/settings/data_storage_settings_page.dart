import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:hondana/core/config/advanced_preferences.dart';
import 'package:hondana/core/core.dart';
import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/network/app_http.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/services/download_service.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:hondana/services/maintenance_service.dart';
import 'package:hondana/features/more/presentation/widgets/settings_widgets.dart';

/// Settings > Data and storage (Mihon SettingsDataScreen minus the deferred
/// backup system): storage usage, chapter-cache maintenance, download wipe.
@RoutePage()
class DataStorageSettingsPage extends StatelessWidget {
  const DataStorageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PageLayoutBuilder(mobile: (context) => const _DataStorageView());
}

class _DataStorageView extends StatefulWidget {
  const _DataStorageView();

  @override
  State<_DataStorageView> createState() => _DataStorageViewState();
}

class _DataStorageViewState extends State<_DataStorageView> {
  final AdvancedPreferences _advanced = getIt<AdvancedPreferences>();
  final MaintenanceService _maintenance = MaintenanceService(
    downloads: getIt<DownloadService>(),
    db: getIt<AppDatabase>(),
    cookies: getIt<WebCookieStore>(),
    sources: getIt<SourceManager>(),
    advanced: getIt<AdvancedPreferences>(),
  );

  final ValueNotifier<({int totalBytes, int mangaCount, int chapterCount})?>
  _usage = ValueNotifier(null);
  final ValueNotifier<int?> _cacheBytes = ValueNotifier(null);
  late final ValueNotifier<bool> _clearOnLaunch = ValueNotifier(
    _advanced.clearCacheOnLaunch,
  );

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _usage.dispose();
    _cacheBytes.dispose();
    _clearOnLaunch.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final usage = await _maintenance.downloadsUsage();
    final cache = await _maintenance.chapterCacheBytes();
    if (!mounted) return;
    _usage.value = usage;
    _cacheBytes.value = cache;
  }

  // Translation-exempt: byte units.
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }

  void _toast(String key) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(key.tr())));
  }

  Future<void> _clearCache() async {
    await _maintenance.clearChapterCache();
    if (!mounted) return;
    _toast('settings.cache_cleared');
    await _refresh();
  }

  Future<void> _deleteAllDownloads() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText.titleMedium('settings.delete_all_downloads'),
        content: const AppText.bodyMedium(
          'settings.delete_all_downloads_confirm',
        ),
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
    await _maintenance.deleteAllDownloads();
    // Rescan so the queue/completed state matches the now-empty disk.
    getIt<DownloadsBloc>().add(const DownloadsStarted());
    if (!mounted) return;
    _toast('settings.downloads_deleted');
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'settings.data_storage'),
      body: ListView(
        children: [
          const SettingsSectionHeader('settings.storage_usage'),
          ValueListenableBuilder<
            ({int totalBytes, int mangaCount, int chapterCount})?
          >(
            valueListenable: _usage,
            builder: (context, usage, _) => ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const AppText.bodyLarge('settings.downloaded_chapters'),
              subtitle: AppText.bodySmall(
                usage == null
                    ? '…'
                    : 'settings.usage_summary'.tr(
                        args: [
                          _formatBytes(usage.totalBytes),
                          '${usage.mangaCount}',
                          '${usage.chapterCount}',
                        ],
                      ),
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: const AppText.bodyLarge('settings.delete_all_downloads'),
            onTap: _deleteAllDownloads,
          ),
          const SettingsSectionHeader('settings.section_cache'),
          ValueListenableBuilder<int?>(
            valueListenable: _cacheBytes,
            builder: (context, bytes, _) => ListTile(
              leading: const Icon(Icons.cached_outlined),
              title: const AppText.bodyLarge('settings.clear_chapter_cache'),
              subtitle: AppText.bodySmall(
                'settings.cache_used'.tr(
                  args: [bytes == null ? '…' : _formatBytes(bytes)],
                ),
                color: context.colorScheme.onSurfaceVariant,
              ),
              onTap: _clearCache,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _clearOnLaunch,
            builder: (context, value, _) => SwitchListTile(
              value: value,
              onChanged: (v) {
                _clearOnLaunch.value = v;
                _advanced.setClearCacheOnLaunch(v);
              },
              title: const AppText.bodyLarge('settings.clear_cache_on_launch'),
            ),
          ),
        ],
      ),
    );
  }
}
