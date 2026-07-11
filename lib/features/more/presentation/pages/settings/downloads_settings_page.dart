import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/features/downloads/domain/download_preferences.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:mihonx/features/library/domain/category.dart';
import 'package:mihonx/features/library/domain/library_repository.dart';
import 'package:mihonx/features/more/presentation/widgets/settings_widgets.dart';

/// Settings > Downloads (Mihon SettingsDownloadScreen parity for the ported
/// preference set).
@RoutePage()
class DownloadsSettingsPage extends StatelessWidget {
  const DownloadsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PageLayoutBuilder(mobile: (context) => const _DownloadsSettingsView());
}

class _DownloadsSettingsView extends StatefulWidget {
  const _DownloadsSettingsView();

  @override
  State<_DownloadsSettingsView> createState() => _DownloadsSettingsViewState();
}

class _DownloadsSettingsViewState extends State<_DownloadsSettingsView> {
  final DownloadPreferences _prefs = getIt<DownloadPreferences>();

  // Read-through page-local notifiers (library settings pattern).
  late final ValueNotifier<bool> _wifiOnly = ValueNotifier(_prefs.wifiOnly);
  late final ValueNotifier<bool> _removeAfterMarkedRead =
      ValueNotifier(_prefs.removeAfterMarkedRead);
  late final ValueNotifier<int> _removeSlots =
      ValueNotifier(_prefs.removeAfterReadSlots);
  late final ValueNotifier<bool> _removeBookmarked =
      ValueNotifier(_prefs.removeBookmarked);
  late final ValueNotifier<Set<int>> _removeExclude =
      ValueNotifier(_prefs.removeExcludeCategoryIds);
  late final ValueNotifier<bool> _downloadNew =
      ValueNotifier(_prefs.downloadNewChapters);
  late final ValueNotifier<(Set<int>, Set<int>)> _downloadNewCategories =
      ValueNotifier(
    (
      _prefs.downloadNewIncludeCategoryIds,
      _prefs.downloadNewExcludeCategoryIds,
    ),
  );
  late final ValueNotifier<int> _downloadAhead =
      ValueNotifier(_prefs.downloadAheadAmount);

  @override
  void dispose() {
    _wifiOnly.dispose();
    _removeAfterMarkedRead.dispose();
    _removeSlots.dispose();
    _removeBookmarked.dispose();
    _removeExclude.dispose();
    _downloadNew.dispose();
    _downloadNewCategories.dispose();
    _downloadAhead.dispose();
    super.dispose();
  }

  String _categoryNames(
    List<Category> categories,
    Set<int> ids,
    String emptyKey,
  ) {
    final names =
        categories.where((c) => ids.contains(c.id)).map((c) => c.name);
    return names.isEmpty ? emptyKey.tr() : names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'settings.downloads'),
      body: StreamBuilder<List<Category>>(
        stream: getIt<LibraryRepository>().watchCategories(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? const <Category>[];
          return ListView(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _wifiOnly,
                builder: (context, wifiOnly, _) => SwitchListTile(
                  value: wifiOnly,
                  // The bloc persists the pref and reschedules the native
                  // tasks' network constraint.
                  onChanged: (v) {
                    _wifiOnly.value = v;
                    getIt<DownloadsBloc>().add(DownloadsWifiOnlyChanged(v));
                  },
                  title: const AppText.bodyLarge('settings.wifi_only'),
                ),
              ),
              const SettingsSectionHeader('settings.section_delete_chapters'),
              ValueListenableBuilder<bool>(
                valueListenable: _removeAfterMarkedRead,
                builder: (context, value, _) => SwitchListTile(
                  value: value,
                  onChanged: (v) {
                    _removeAfterMarkedRead.value = v;
                    _prefs.setRemoveAfterMarkedRead(v);
                  },
                  title: const AppText.bodyLarge(
                    'settings.remove_after_marked_read',
                  ),
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: _removeSlots,
                builder: (context, slots, _) => ListTile(
                  title: const AppText.bodyLarge('settings.remove_after_read'),
                  subtitle: AppText.bodySmall(
                    _removeSlotKey(slots),
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onTap: () => OptionPickerSheet.show<int>(
                    context,
                    values: const [-1, 0, 1, 2, 3, 4],
                    selected: slots,
                    labelKey: _removeSlotKey,
                  ).then((picked) {
                    if (picked != null) {
                      _removeSlots.value = picked;
                      _prefs.setRemoveAfterReadSlots(picked);
                    }
                  }),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _removeBookmarked,
                builder: (context, value, _) => SwitchListTile(
                  value: value,
                  onChanged: (v) {
                    _removeBookmarked.value = v;
                    _prefs.setRemoveBookmarked(v);
                  },
                  title:
                      const AppText.bodyLarge('settings.remove_bookmarked'),
                ),
              ),
              ValueListenableBuilder<Set<int>>(
                valueListenable: _removeExclude,
                builder: (context, ids, _) => ListTile(
                  title: const AppText.bodyLarge(
                    'settings.remove_exclude_categories',
                  ),
                  subtitle: AppText.bodySmall(
                    _categoryNames(categories, ids, 'settings.none'),
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onTap: () => MultiPickerSheet.show<int>(
                    context,
                    values: categories.map((c) => c.id).toList(),
                    selected: ids,
                    label: (id) =>
                        categories.firstWhere((c) => c.id == id).name,
                  ).then((picked) {
                    if (picked != null) {
                      _removeExclude.value = picked;
                      _prefs.setRemoveExcludeCategoryIds(picked);
                    }
                  }),
                ),
              ),
              const SettingsSectionHeader('settings.section_auto_download'),
              ValueListenableBuilder<bool>(
                valueListenable: _downloadNew,
                builder: (context, value, _) => SwitchListTile(
                  value: value,
                  onChanged: (v) {
                    _downloadNew.value = v;
                    _prefs.setDownloadNewChapters(v);
                  },
                  title: const AppText.bodyLarge('settings.download_new'),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _downloadNew,
                builder: (context, enabled, _) =>
                    ValueListenableBuilder<(Set<int>, Set<int>)>(
                  valueListenable: _downloadNewCategories,
                  builder: (context, sets, _) {
                    final (include, exclude) = sets;
                    final summary = [
                      'settings.include'.tr(
                        args: [
                          _categoryNames(categories, include, 'library.all'),
                        ],
                      ),
                      'settings.exclude'.tr(
                        args: [
                          _categoryNames(categories, exclude, 'settings.none'),
                        ],
                      ),
                    ].join('\n');
                    return ListTile(
                      enabled: enabled,
                      title: const AppText.bodyLarge('categories.title'),
                      subtitle: AppText.bodySmall(
                        summary,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      onTap: enabled
                          ? () => TriStateSheet.show(
                                context,
                                items: {
                                  for (final c in categories) c.id: c.name,
                                },
                                include: include,
                                exclude: exclude,
                              ).then((picked) {
                                if (picked != null) {
                                  _downloadNewCategories.value = picked;
                                  _prefs.setDownloadNewIncludeCategoryIds(
                                    picked.$1,
                                  );
                                  _prefs.setDownloadNewExcludeCategoryIds(
                                    picked.$2,
                                  );
                                }
                              })
                          : null,
                    );
                  },
                ),
              ),
              const SettingsSectionHeader('settings.section_download_ahead'),
              ValueListenableBuilder<int>(
                valueListenable: _downloadAhead,
                builder: (context, amount, _) => ListTile(
                  title: const AppText.bodyLarge('settings.download_ahead'),
                  subtitle: AppText.bodySmall(
                    'settings.download_ahead_$amount',
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onTap: () => OptionPickerSheet.show<int>(
                    context,
                    values: const [0, 2, 3, 5, 10],
                    selected: amount,
                    labelKey: (v) => 'settings.download_ahead_$v',
                  ).then((picked) {
                    if (picked != null) {
                      _downloadAhead.value = picked;
                      _prefs.setDownloadAheadAmount(picked);
                    }
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _removeSlotKey(int v) =>
      'settings.remove_slot_${v < 0 ? 'disabled' : v}';
}
