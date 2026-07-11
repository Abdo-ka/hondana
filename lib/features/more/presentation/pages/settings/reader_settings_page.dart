import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/more/presentation/widgets/settings_widgets.dart';
import 'package:hondana/features/reader/domain/reader_preferences.dart';

/// Settings > Reader (Mihon SettingsReaderScreen parity for the ported
/// preference set). [ReaderPreferences] is a ChangeNotifier, so the list
/// reads live values and an open reader applies changes immediately.
@RoutePage()
class ReaderSettingsPage extends StatelessWidget {
  const ReaderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => PageLayoutBuilder(
    mobile: (context) => const AppScaffold(
      appBar: AppAppBar(title: 'settings.reader'),
      body: _ReaderSettingsList(),
    ),
  );
}

class _ReaderSettingsList extends StatelessWidget {
  const _ReaderSettingsList();

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<ReaderPreferences>();
    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) => ListView(
        children: [
          _PickerTile<ReadingMode>(
            titleKey: 'settings.default_reading_mode',
            value: prefs.readingMode,
            values: ReadingMode.values,
            labelKey: (m) => 'reader.mode_${m.name}',
            onChanged: prefs.setReadingMode,
          ),
          _PickerTile<DoubleTapSpeed>(
            titleKey: 'settings.double_tap_speed',
            value: prefs.doubleTapSpeed,
            values: DoubleTapSpeed.values,
            labelKey: (v) => 'settings.double_tap_speed_${v.name}',
            onChanged: prefs.setDoubleTapSpeed,
          ),
          _SwitchTile(
            titleKey: 'settings.show_reading_mode',
            subtitleKey: 'settings.show_reading_mode_hint',
            value: prefs.showReadingMode,
            onChanged: prefs.setShowReadingMode,
          ),
          _SwitchTile(
            titleKey: 'settings.animate_transitions',
            value: prefs.animatePageTransitions,
            onChanged: prefs.setAnimatePageTransitions,
          ),
          _PickerTile<ReaderOrientation>(
            titleKey: 'settings.rotation',
            value: prefs.orientation,
            values: ReaderOrientation.values,
            labelKey: (v) => 'settings.rotation_${v.name}',
            onChanged: prefs.setOrientation,
          ),
          const SettingsSectionHeader('settings.section_display'),
          _PickerTile<ReaderBackground>(
            titleKey: 'settings.background_color',
            value: prefs.background,
            values: ReaderBackground.values,
            labelKey: (v) => 'settings.background_${v.name}',
            onChanged: prefs.setBackground,
          ),
          _SwitchTile(
            titleKey: 'settings.fullscreen',
            value: prefs.fullscreen,
            onChanged: prefs.setFullscreen,
          ),
          _SwitchTile(
            titleKey: 'settings.keep_screen_on',
            value: prefs.keepScreenOn,
            onChanged: prefs.setKeepScreenOn,
          ),
          _SwitchTile(
            titleKey: 'settings.show_page_number',
            value: prefs.showPageNumber,
            onChanged: prefs.setShowPageNumber,
          ),
          const SettingsSectionHeader('settings.section_reading'),
          _SwitchTile(
            titleKey: 'settings.skip_read',
            value: prefs.skipRead,
            onChanged: prefs.setSkipRead,
          ),
          _SwitchTile(
            titleKey: 'settings.skip_duplicates',
            value: prefs.skipDuplicates,
            onChanged: prefs.setSkipDuplicates,
          ),
          _SwitchTile(
            titleKey: 'settings.always_show_transition',
            value: prefs.alwaysShowTransition,
            onChanged: prefs.setAlwaysShowTransition,
          ),
          const SettingsSectionHeader('settings.section_paged'),
          _PickerTile<ReaderNavLayout>(
            titleKey: 'settings.tap_zones',
            value: prefs.navLayoutPaged,
            values: ReaderNavLayout.values,
            labelKey: (v) => 'settings.nav_${v.name}',
            onChanged: prefs.setNavLayoutPaged,
          ),
          _PickerTile<ReaderNavInvert>(
            titleKey: 'settings.invert_tap_zones',
            value: prefs.navInvertPaged,
            values: ReaderNavInvert.values,
            labelKey: (v) => 'settings.nav_invert_${v.name}',
            onChanged: prefs.setNavInvertPaged,
            enabled: prefs.navLayoutPaged != ReaderNavLayout.disabled,
          ),
          _PickerTile<ReaderScaleType>(
            titleKey: 'settings.scale_type',
            value: prefs.scaleType,
            values: ReaderScaleType.values,
            labelKey: (v) => 'settings.scale_${v.name}',
            onChanged: prefs.setScaleType,
          ),
          const SettingsSectionHeader('settings.section_webtoon'),
          _PickerTile<ReaderNavLayout>(
            titleKey: 'settings.tap_zones',
            value: prefs.navLayoutWebtoon,
            values: ReaderNavLayout.values,
            labelKey: (v) => 'settings.nav_${v.name}',
            onChanged: prefs.setNavLayoutWebtoon,
          ),
          _PickerTile<ReaderNavInvert>(
            titleKey: 'settings.invert_tap_zones',
            value: prefs.navInvertWebtoon,
            values: ReaderNavInvert.values,
            labelKey: (v) => 'settings.nav_invert_${v.name}',
            onChanged: prefs.setNavInvertWebtoon,
            enabled: prefs.navLayoutWebtoon != ReaderNavLayout.disabled,
          ),
          _SliderTile(
            titleKey: 'settings.side_padding',
            value: prefs.sidePadding,
            min: 0,
            max: 25,
            onChanged: prefs.setSidePadding,
          ),
          _SwitchTile(
            titleKey: 'settings.double_tap_zoom',
            value: prefs.doubleTapZoomWebtoon,
            onChanged: prefs.setDoubleTapZoomWebtoon,
          ),
          const SettingsSectionHeader('settings.section_filter'),
          _SwitchTile(
            titleKey: 'settings.custom_brightness',
            value: prefs.customBrightness,
            onChanged: prefs.setCustomBrightness,
          ),
          _SliderTile(
            titleKey: 'settings.custom_brightness_value',
            value: prefs.brightnessValue,
            min: -75,
            max: 100,
            onChanged: prefs.setBrightnessValue,
            enabled: prefs.customBrightness,
          ),
          _SwitchTile(
            titleKey: 'settings.color_filter',
            value: prefs.colorFilter,
            onChanged: prefs.setColorFilter,
          ),
          _SliderTile(
            titleKey: 'settings.filter_red',
            value: prefs.filterRed,
            min: 0,
            max: 255,
            onChanged: prefs.setFilterRed,
            enabled: prefs.colorFilter,
          ),
          _SliderTile(
            titleKey: 'settings.filter_green',
            value: prefs.filterGreen,
            min: 0,
            max: 255,
            onChanged: prefs.setFilterGreen,
            enabled: prefs.colorFilter,
          ),
          _SliderTile(
            titleKey: 'settings.filter_blue',
            value: prefs.filterBlue,
            min: 0,
            max: 255,
            onChanged: prefs.setFilterBlue,
            enabled: prefs.colorFilter,
          ),
          _SliderTile(
            titleKey: 'settings.filter_alpha',
            value: prefs.filterAlpha,
            min: 0,
            max: 255,
            onChanged: prefs.setFilterAlpha,
            enabled: prefs.colorFilter,
          ),
          _PickerTile<ReaderBlendMode>(
            titleKey: 'settings.filter_blend',
            value: prefs.filterBlend,
            values: ReaderBlendMode.values,
            labelKey: (v) => 'settings.blend_${v.name}',
            onChanged: prefs.setFilterBlend,
            enabled: prefs.colorFilter,
          ),
          _SwitchTile(
            titleKey: 'settings.grayscale',
            value: prefs.grayscale,
            onChanged: prefs.setGrayscale,
          ),
          _SwitchTile(
            titleKey: 'settings.inverted_colors',
            value: prefs.invertedColors,
            onChanged: prefs.setInvertedColors,
          ),
        ],
      ),
    );
  }
}

/// Boolean pref row backed by a [SwitchListTile].
class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.titleKey,
    required this.value,
    required this.onChanged,
    this.subtitleKey,
  });

  final String titleKey;
  final String? subtitleKey;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    value: value,
    onChanged: onChanged,
    title: AppText.bodyLarge(titleKey),
    subtitle: subtitleKey == null
        ? null
        : AppText.bodySmall(
            subtitleKey!,
            color: context.colorScheme.onSurfaceVariant,
          ),
  );
}

/// Enum pref row that opens an [OptionPickerSheet] to choose one of [values].
class _PickerTile<T> extends StatelessWidget {
  const _PickerTile({
    required this.titleKey,
    required this.value,
    required this.values,
    required this.labelKey,
    required this.onChanged,
    this.enabled = true,
  });

  final String titleKey;
  final T value;
  final List<T> values;
  final String Function(T) labelKey;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => ListTile(
    enabled: enabled,
    title: AppText.bodyLarge(titleKey),
    subtitle: AppText.bodySmall(
      labelKey(value),
      color: context.colorScheme.onSurfaceVariant,
    ),
    onTap: enabled
        ? () =>
              OptionPickerSheet.show<T>(
                context,
                values: values,
                selected: value,
                labelKey: labelKey,
              ).then((picked) {
                if (picked != null) onChanged(picked);
              })
        : null,
  );
}

/// Integer pref row with a live value label and a clamped [Slider].
class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.titleKey,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.enabled = true,
  });

  final String titleKey;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => ListTile(
    enabled: enabled,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.bodyLarge(titleKey),
        AppText.bodyMedium(
          '$value',
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
    ),
    subtitle: Slider(
      value: value.clamp(min, max).toDouble(),
      min: min.toDouble(),
      max: max.toDouble(),
      divisions: max - min,
      onChanged: enabled ? (v) => onChanged(v.round()) : null,
    ),
  );
}
