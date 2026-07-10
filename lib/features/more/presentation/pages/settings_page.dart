import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/config/app_settings.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/features/reader/domain/reader_preferences.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PageLayoutBuilder(mobile: (context) => const _SettingsView());
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final AppSettings _settings = getIt<AppSettings>();
  final ReaderPreferences _readerPrefs = getIt<ReaderPreferences>();
  late final ValueNotifier<ReadingMode> _readingMode =
      ValueNotifier(_readerPrefs.readingMode);

  @override
  void dispose() {
    _readingMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'settings.title'),
      body: ListView(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: _settings.themeModeNotifier,
            builder: (context, mode, _) => ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const AppText.bodyLarge('settings.theme'),
              subtitle: AppText.bodySmall(
                'settings.theme_${mode.name}',
                color: context.colorScheme.onSurfaceVariant,
              ),
              onTap: () => _OptionPickerSheet.show<ThemeMode>(
                context,
                values: ThemeMode.values,
                selected: mode,
                labelKey: (m) => 'settings.theme_${m.name}',
              ).then((picked) {
                if (picked != null) _settings.setThemeMode(picked);
              }),
            ),
          ),
          ValueListenableBuilder<ReadingMode>(
            valueListenable: _readingMode,
            builder: (context, mode, _) => ListTile(
              leading: const Icon(Icons.chrome_reader_mode_outlined),
              title: const AppText.bodyLarge('settings.default_reading_mode'),
              subtitle: AppText.bodySmall(
                'reader.mode_${mode.name}',
                color: context.colorScheme.onSurfaceVariant,
              ),
              onTap: () => _OptionPickerSheet.show<ReadingMode>(
                context,
                values: ReadingMode.values,
                selected: mode,
                labelKey: (m) => 'reader.mode_${m.name}',
              ).then((picked) {
                if (picked != null) {
                  _readingMode.value = picked;
                  _readerPrefs.setReadingMode(picked);
                }
              }),
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: AppText.bodyLarge('settings.about'),
            subtitle: AppText.bodySmall('0.1.0'),
          ),
        ],
      ),
    );
  }
}

/// Generic single-choice bottom sheet returning the picked value.
class _OptionPickerSheet<T> extends StatelessWidget {
  const _OptionPickerSheet({
    required this.values,
    required this.selected,
    required this.labelKey,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelKey;

  static Future<T?> show<T>(
    BuildContext context, {
    required List<T> values,
    required T selected,
    required String Function(T) labelKey,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (_) => _OptionPickerSheet<T>(
        values: values,
        selected: selected,
        labelKey: labelKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: values
            .map(
              (v) => ListTile(
                title: AppText.bodyMedium(labelKey(v)),
                trailing: v == selected
                    ? Icon(Icons.check, color: context.colorScheme.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(v),
              ),
            )
            .toList(),
      ),
    );
  }
}
