import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/routing/app_router.gr.dart';
import 'package:hondana/features/library/domain/category.dart';
import 'package:hondana/features/library/domain/library_preferences.dart';
import 'package:hondana/features/library/domain/library_repository.dart';
import 'package:hondana/features/more/presentation/widgets/settings_widgets.dart';

/// Settings > Library (Mihon SettingsLibraryScreen parity).
@RoutePage()
class LibrarySettingsPage extends StatelessWidget {
  const LibrarySettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PageLayoutBuilder(mobile: (context) => const _LibrarySettingsView());
}

class _LibrarySettingsView extends StatefulWidget {
  const _LibrarySettingsView();

  @override
  State<_LibrarySettingsView> createState() => _LibrarySettingsViewState();
}

class _LibrarySettingsViewState extends State<_LibrarySettingsView> {
  final LibraryPreferences _prefs = getIt<LibraryPreferences>();

  // Read-through page-local notifiers (settings_page.dart pattern).
  late final ValueNotifier<int> _defaultCategory = ValueNotifier(
    _prefs.defaultCategoryId,
  );
  late final ValueNotifier<int> _interval = ValueNotifier(
    _prefs.updateIntervalHours,
  );
  late final ValueNotifier<bool> _wifiOnly = ValueNotifier(
    _prefs.updateWifiOnly,
  );
  late final ValueNotifier<(Set<int>, Set<int>)> _updateCategories =
      ValueNotifier((
        _prefs.updateIncludeCategoryIds,
        _prefs.updateExcludeCategoryIds,
      ));
  late final ValueNotifier<bool> _refreshMetadata = ValueNotifier(
    _prefs.autoRefreshMetadata,
  );
  late final ValueNotifier<bool> _skipUnread = ValueNotifier(
    _prefs.skipUpdateWithUnread,
  );
  late final ValueNotifier<bool> _skipUnstarted = ValueNotifier(
    _prefs.skipUpdateUnstarted,
  );
  late final ValueNotifier<bool> _skipCompleted = ValueNotifier(
    _prefs.skipUpdateCompleted,
  );
  late final ValueNotifier<ChapterSwipeAction> _swipeLeft = ValueNotifier(
    _prefs.swipeLeftAction,
  );
  late final ValueNotifier<ChapterSwipeAction> _swipeRight = ValueNotifier(
    _prefs.swipeRightAction,
  );
  late final ValueNotifier<bool> _showBadge = ValueNotifier(
    _prefs.showUpdatesBadge,
  );

  @override
  void dispose() {
    _defaultCategory.dispose();
    _interval.dispose();
    _wifiOnly.dispose();
    _updateCategories.dispose();
    _refreshMetadata.dispose();
    _skipUnread.dispose();
    _skipUnstarted.dispose();
    _skipCompleted.dispose();
    _swipeLeft.dispose();
    _swipeRight.dispose();
    _showBadge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'settings.library'),
      body: StreamBuilder<List<Category>>(
        stream: getIt<LibraryRepository>().watchCategories(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? const <Category>[];
          return ListView(
            children: [
              const SettingsSectionHeader('categories.title'),
              _EditCategoriesTile(count: categories.length),
              _DefaultCategoryTile(
                categories: categories,
                notifier: _defaultCategory,
                onChanged: (id) {
                  _defaultCategory.value = id;
                  _prefs.setDefaultCategoryId(id);
                },
              ),
              const SettingsSectionHeader('settings.global_update'),
              _UpdateIntervalTile(
                notifier: _interval,
                onChanged: (hours) {
                  _interval.value = hours;
                  _prefs.setUpdateIntervalHours(hours);
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: _interval,
                builder: (context, hours, _) => _SwitchTile(
                  titleKey: 'settings.wifi_only',
                  notifier: _wifiOnly,
                  enabled: hours > 0,
                  onChanged: (v) {
                    _wifiOnly.value = v;
                    _prefs.setUpdateWifiOnly(v);
                  },
                ),
              ),
              _UpdateCategoriesTile(
                categories: categories,
                notifier: _updateCategories,
                onChanged: (sets) {
                  _updateCategories.value = sets;
                  _prefs.setUpdateIncludeCategoryIds(sets.$1);
                  _prefs.setUpdateExcludeCategoryIds(sets.$2);
                },
              ),
              _SwitchTile(
                titleKey: 'settings.auto_refresh_metadata',
                subtitleKey: 'settings.auto_refresh_metadata_hint',
                notifier: _refreshMetadata,
                onChanged: (v) {
                  _refreshMetadata.value = v;
                  _prefs.setAutoRefreshMetadata(v);
                },
              ),
              _SwitchTile(
                titleKey: 'settings.skip_update_with_unread',
                notifier: _skipUnread,
                onChanged: (v) {
                  _skipUnread.value = v;
                  _prefs.setSkipUpdateWithUnread(v);
                },
              ),
              _SwitchTile(
                titleKey: 'settings.skip_update_unstarted',
                notifier: _skipUnstarted,
                onChanged: (v) {
                  _skipUnstarted.value = v;
                  _prefs.setSkipUpdateUnstarted(v);
                },
              ),
              _SwitchTile(
                titleKey: 'settings.skip_update_completed',
                notifier: _skipCompleted,
                onChanged: (v) {
                  _skipCompleted.value = v;
                  _prefs.setSkipUpdateCompleted(v);
                },
              ),
              const SettingsSectionHeader('manga.chapters'),
              _SwipeActionTile(
                titleKey: 'settings.swipe_left',
                notifier: _swipeLeft,
                onChanged: (a) {
                  _swipeLeft.value = a;
                  _prefs.setSwipeLeftAction(a);
                },
              ),
              _SwipeActionTile(
                titleKey: 'settings.swipe_right',
                notifier: _swipeRight,
                onChanged: (a) {
                  _swipeRight.value = a;
                  _prefs.setSwipeRightAction(a);
                },
              ),
              const SettingsSectionHeader('nav.updates'),
              _SwitchTile(
                titleKey: 'settings.show_updates_badge',
                notifier: _showBadge,
                onChanged: (v) {
                  _showBadge.value = v;
                  _prefs.setShowUpdatesBadge(v);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Row showing the category count; taps through to the category editor.
class _EditCategoriesTile extends StatelessWidget {
  const _EditCategoriesTile({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.label_outline),
      title: const AppText.bodyLarge('settings.edit_categories'),
      subtitle: AppText.bodySmall(
        'settings.n_categories'.tr(args: ['$count']),
        color: context.colorScheme.onSurfaceVariant,
      ),
      onTap: () => context.router.push(const CategoriesRoute()),
    );
  }
}

/// Picks the category new library entries default into (-1 = always ask).
class _DefaultCategoryTile extends StatelessWidget {
  const _DefaultCategoryTile({
    required this.categories,
    required this.notifier,
    required this.onChanged,
  });

  final List<Category> categories;
  final ValueNotifier<int> notifier;
  final ValueChanged<int> onChanged;

  String _label(int id) =>
      categories.firstWhereOrNull((c) => c.id == id)?.name ??
      'settings.default_category_always_ask';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, id, _) => ListTile(
        title: const AppText.bodyLarge('settings.default_category'),
        subtitle: AppText.bodySmall(
          _label(id),
          color: context.colorScheme.onSurfaceVariant,
        ),
        onTap: () =>
            OptionPickerSheet.show<int>(
              context,
              values: [-1, ...categories.map((c) => c.id)],
              selected: categories.any((c) => c.id == id) ? id : -1,
              labelKey: _label,
            ).then((picked) {
              if (picked != null) onChanged(picked);
            }),
      ),
    );
  }
}

/// Picks how often the global library update runs (0 = off).
class _UpdateIntervalTile extends StatelessWidget {
  const _UpdateIntervalTile({required this.notifier, required this.onChanged});

  /// Mihon's interval choices, in hours (0 = off).
  static const _intervals = [0, 12, 24, 48, 72, 168];

  final ValueNotifier<int> notifier;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, hours, _) => ListTile(
        title: const AppText.bodyLarge('settings.update_interval'),
        subtitle: AppText.bodySmall(
          'settings.update_interval_$hours',
          color: context.colorScheme.onSurfaceVariant,
        ),
        onTap: () =>
            OptionPickerSheet.show<int>(
              context,
              values: _intervals,
              selected: hours,
              labelKey: (h) => 'settings.update_interval_$h',
            ).then((picked) {
              if (picked != null) onChanged(picked);
            }),
      ),
    );
  }
}

/// Tri-state include/exclude filter of which categories the global update
/// touches, via [TriStateSheet].
class _UpdateCategoriesTile extends StatelessWidget {
  const _UpdateCategoriesTile({
    required this.categories,
    required this.notifier,
    required this.onChanged,
  });

  final List<Category> categories;
  final ValueNotifier<(Set<int>, Set<int>)> notifier;
  final ValueChanged<(Set<int>, Set<int>)> onChanged;

  String _names(Set<int> ids, String emptyKey) {
    final names = categories
        .where((c) => ids.contains(c.id))
        .map((c) => c.name);
    return names.isEmpty ? emptyKey.tr() : names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<(Set<int>, Set<int>)>(
      valueListenable: notifier,
      builder: (context, sets, _) {
        final (include, exclude) = sets;
        final summary = [
          'settings.include'.tr(args: [_names(include, 'library.all')]),
          'settings.exclude'.tr(args: [_names(exclude, 'settings.none')]),
        ].join('\n');
        return ListTile(
          title: const AppText.bodyLarge('categories.title'),
          subtitle: AppText.bodySmall(
            summary,
            color: context.colorScheme.onSurfaceVariant,
          ),
          onTap: () =>
              TriStateSheet.show(
                context,
                items: {for (final c in categories) c.id: c.name},
                include: include,
                exclude: exclude,
              ).then((picked) {
                if (picked != null) onChanged(picked);
              }),
        );
      },
    );
  }
}

/// Picks the [ChapterSwipeAction] bound to a swipe direction in the library.
class _SwipeActionTile extends StatelessWidget {
  const _SwipeActionTile({
    required this.titleKey,
    required this.notifier,
    required this.onChanged,
  });

  final String titleKey;
  final ValueNotifier<ChapterSwipeAction> notifier;
  final ValueChanged<ChapterSwipeAction> onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ChapterSwipeAction>(
      valueListenable: notifier,
      builder: (context, action, _) => ListTile(
        title: AppText.bodyLarge(titleKey),
        subtitle: AppText.bodySmall(
          'settings.swipe_action_${action.name}',
          color: context.colorScheme.onSurfaceVariant,
        ),
        onTap: () =>
            OptionPickerSheet.show<ChapterSwipeAction>(
              context,
              values: ChapterSwipeAction.values,
              selected: action,
              labelKey: (a) => 'settings.swipe_action_${a.name}',
            ).then((picked) {
              if (picked != null) onChanged(picked);
            }),
      ),
    );
  }
}

/// Boolean pref row driven by a [ValueNotifier], optionally disabled.
class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.titleKey,
    required this.notifier,
    required this.onChanged,
    this.subtitleKey,
    this.enabled = true,
  });

  final String titleKey;
  final String? subtitleKey;
  final ValueNotifier<bool> notifier;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, _) => SwitchListTile(
        value: value,
        onChanged: enabled ? onChanged : null,
        title: AppText.bodyLarge(titleKey),
        subtitle: subtitleKey == null
            ? null
            : AppText.bodySmall(
                subtitleKey!,
                color: context.colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}
