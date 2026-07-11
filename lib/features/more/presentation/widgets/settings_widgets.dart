import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/core.dart';

/// Shared building blocks for the settings screens.

/// Mihon-style section header inside a settings list.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader(this.labelKey, {super.key});

  /// Translation key for the section title.
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
      child: AppText.labelMedium(labelKey, color: context.colorScheme.primary),
    );
  }
}

/// Generic single-choice bottom sheet returning the picked value.
class OptionPickerSheet<T> extends StatelessWidget {
  const OptionPickerSheet({
    required this.values,
    required this.selected,
    required this.labelKey,
    super.key,
  });

  final List<T> values;
  final T selected;

  /// Translation key (or already-translated label) per option.
  final String Function(T) labelKey;

  /// Presents the sheet and completes with the chosen value, or null if
  /// dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    required List<T> values,
    required T selected,
    required String Function(T) labelKey,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (_) => OptionPickerSheet<T>(
        values: values,
        selected: selected,
        labelKey: labelKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
      ),
    );
  }
}

/// Multi-choice bottom sheet over arbitrary items; returns the new selection
/// (or null when dismissed).
class MultiPickerSheet<T> extends StatefulWidget {
  const MultiPickerSheet({
    required this.values,
    required this.selected,
    required this.label,
    super.key,
  });

  final List<T> values;
  final Set<T> selected;

  /// Already-translated label per item (dynamic values like category names
  /// flow through AppText.tr() unchanged).
  final String Function(T) label;

  /// Presents the sheet and completes with the new selection, or null if
  /// dismissed.
  static Future<Set<T>?> show<T>(
    BuildContext context, {
    required List<T> values,
    required Set<T> selected,
    required String Function(T) label,
  }) {
    return showModalBottomSheet<Set<T>>(
      context: context,
      showDragHandle: true,
      builder: (_) =>
          MultiPickerSheet<T>(values: values, selected: selected, label: label),
    );
  }

  @override
  State<MultiPickerSheet<T>> createState() => _MultiPickerSheetState<T>();
}

class _MultiPickerSheetState<T> extends State<MultiPickerSheet<T>> {
  late final ValueNotifier<Set<T>> _selection = ValueNotifier({
    ...widget.selected,
  });

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<Set<T>>(
        valueListenable: _selection,
        builder: (context, selection, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.values
                      .map(
                        (v) => CheckboxListTile(
                          value: selection.contains(v),
                          title: AppText.bodyMedium(widget.label(v)),
                          onChanged: (checked) => _selection.value = {
                            ...selection..remove(v),
                            if (checked ?? false) v,
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(_selection.value),
                  child: const AppText.bodyMedium('common.ok'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mihon's tri-state category filter (include / exclude / neutral per item).
/// Returns the new (include, exclude) id sets, or null when dismissed.
class TriStateSheet extends StatefulWidget {
  const TriStateSheet({
    required this.items,
    required this.include,
    required this.exclude,
    super.key,
  });

  /// id → display label (already translated).
  final Map<int, String> items;
  final Set<int> include;
  final Set<int> exclude;

  /// Presents the sheet and completes with the new (include, exclude) id sets,
  /// or null if dismissed.
  static Future<(Set<int>, Set<int>)?> show(
    BuildContext context, {
    required Map<int, String> items,
    required Set<int> include,
    required Set<int> exclude,
  }) {
    return showModalBottomSheet<(Set<int>, Set<int>)>(
      context: context,
      showDragHandle: true,
      builder: (_) =>
          TriStateSheet(items: items, include: include, exclude: exclude),
    );
  }

  @override
  State<TriStateSheet> createState() => _TriStateSheetState();
}

class _TriStateSheetState extends State<TriStateSheet> {
  /// (include, exclude) — one notifier so a cycle updates both atomically.
  late final ValueNotifier<(Set<int>, Set<int>)> _state = ValueNotifier((
    {...widget.include},
    {...widget.exclude},
  ));

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _cycle(int id) {
    final (include, exclude) = _state.value;
    if (include.contains(id)) {
      _state.value = ({...include}..remove(id), {...exclude, id});
    } else if (exclude.contains(id)) {
      _state.value = (include, {...exclude}..remove(id));
    } else {
      _state.value = ({...include, id}, exclude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<(Set<int>, Set<int>)>(
        valueListenable: _state,
        builder: (context, state, _) {
          final (include, exclude) = state;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.items.entries
                        .map(
                          (e) => ListTile(
                            leading: Icon(
                              include.contains(e.key)
                                  ? Icons.check_box
                                  : exclude.contains(e.key)
                                  ? Icons.disabled_by_default
                                  : Icons.check_box_outline_blank,
                              color: include.contains(e.key)
                                  ? context.colorScheme.primary
                                  : exclude.contains(e.key)
                                  ? context.colorScheme.error
                                  : null,
                            ),
                            title: AppText.bodyMedium(e.value),
                            onTap: () => _cycle(e.key),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(state),
                    child: const AppText.bodyMedium('common.ok'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
