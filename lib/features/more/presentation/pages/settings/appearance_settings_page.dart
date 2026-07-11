import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:hondana/core/config/app_settings.dart';
import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/more/presentation/widgets/settings_widgets.dart';

/// Settings > Appearance (Mihon SettingsAppearanceScreen) — theme mode, pure
/// black, and display options (locale, date format, relative timestamps).
@RoutePage()
class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PageLayoutBuilder(mobile: (context) => const _AppearanceView());
}

class _AppearanceView extends StatelessWidget {
  const _AppearanceView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'settings.appearance'),
      body: ListView(
        children: const [
          SettingsSectionHeader('settings.section_theme'),
          _ThemeModeTile(),
          _PureBlackTile(),
          Divider(),
          SettingsSectionHeader('settings.section_display'),
          _AppLanguageTile(),
          _DateFormatTile(),
          _RelativeTimestampsTile(),
        ],
      ),
    );
  }
}

/// App theme mode: Light / Dark / System (Mihon default System).
class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettings>();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: settings.themeModeNotifier,
      builder: (context, mode, _) => ListTile(
        title: const AppText.bodyLarge('settings.app_theme'),
        subtitle: AppText.bodySmall(
          'settings.theme_${mode.name}',
          color: context.colorScheme.onSurfaceVariant,
        ),
        onTap: () =>
            OptionPickerSheet.show<ThemeMode>(
              context,
              values: ThemeMode.values,
              selected: mode,
              labelKey: (m) => 'settings.theme_${m.name}',
            ).then((picked) {
              if (picked != null) settings.setThemeMode(picked);
            }),
      ),
    );
  }
}

/// Pure black dark mode — disabled when theme mode is Light, like Mihon.
class _PureBlackTile extends StatelessWidget {
  const _PureBlackTile();

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettings>();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: settings.themeModeNotifier,
      builder: (context, mode, _) => ValueListenableBuilder<bool>(
        valueListenable: settings.pureBlackNotifier,
        builder: (context, pureBlack, _) => SwitchListTile(
          value: pureBlack,
          onChanged: mode == ThemeMode.light ? null : settings.setPureBlack,
          title: const AppText.bodyLarge('settings.pure_black'),
        ),
      ),
    );
  }
}

/// In-app locale override; each locale is shown under its own (endonym) name.
class _AppLanguageTile extends StatelessWidget {
  const _AppLanguageTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const AppText.bodyLarge('settings.app_language'),
      subtitle: AppText.bodySmall(
        _localeDisplayName(context.locale),
        color: context.colorScheme.onSurfaceVariant,
      ),
      onTap: () =>
          OptionPickerSheet.show<Locale>(
            context,
            values: context.supportedLocales,
            selected: context.locale,
            labelKey: _localeDisplayName,
          ).then((picked) {
            if (picked != null && context.mounted) context.setLocale(picked);
          }),
    );
  }
}

/// Date format — each choice previews today's date, like Mihon.
class _DateFormatTile extends StatelessWidget {
  const _DateFormatTile();

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettings>();
    return ValueListenableBuilder<String>(
      valueListenable: settings.dateFormatNotifier,
      builder: (context, format, _) => ListTile(
        title: const AppText.bodyLarge('settings.date_format'),
        subtitle: AppText.bodySmall(
          _dateFormatLabel(format),
          color: context.colorScheme.onSurfaceVariant,
        ),
        onTap: () =>
            OptionPickerSheet.show<String>(
              context,
              values: AppSettings.dateFormats,
              selected: format,
              labelKey: _dateFormatLabel,
            ).then((picked) {
              if (picked != null) settings.setDateFormat(picked);
            }),
      ),
    );
  }
}

/// Relative timestamps (Mihon default on); the subtitle previews today's date
/// in the currently selected format.
class _RelativeTimestampsTile extends StatelessWidget {
  const _RelativeTimestampsTile();

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettings>();
    return ValueListenableBuilder<bool>(
      valueListenable: settings.relativeTimestampsNotifier,
      builder: (context, relative, _) => ValueListenableBuilder<String>(
        valueListenable: settings.dateFormatNotifier,
        builder: (context, format, _) => SwitchListTile(
          value: relative,
          onChanged: settings.setRelativeTimestamps,
          title: const AppText.bodyLarge('settings.relative_timestamps'),
          subtitle: AppText.bodySmall(
            'settings.relative_timestamps_summary'.tr(
              namedArgs: {'date': _todayIn(format)},
            ),
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// A locale's own name — language endonyms are proper nouns and stay
/// untranslated by design (dynamic strings pass through AppText unchanged).
String _localeDisplayName(Locale locale) {
  const names = {'en': 'English', 'ar': 'العربية'};
  return names[locale.languageCode] ?? locale.toLanguageTag();
}

/// Picker/subtitle label: "MM/dd/yy (07/11/26)"; '' = "Default (7/11/2026)".
String _dateFormatLabel(String format) {
  final name = format.isEmpty ? 'settings.date_format_default'.tr() : format;
  return '$name (${_todayIn(format)})';
}

/// Today's date rendered in [format] ('' = locale short date).
String _todayIn(String format) {
  final now = DateTime.now();
  return format.isEmpty
      ? DateFormat.yMd().format(now)
      : DateFormat(format).format(now);
}
