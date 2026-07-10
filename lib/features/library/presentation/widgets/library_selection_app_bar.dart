import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mihonx/core/extensions/context_ext.dart';
import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/library/domain/category.dart';
import 'package:mihonx/features/library/presentation/bloc/library_bloc.dart';
import 'package:mihonx/features/library/presentation/bloc/library_event.dart';

/// Contextual app bar shown while items are selected.
class LibrarySelectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const LibrarySelectionAppBar({required this.count, super.key});

  final int count;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () =>
            context.read<LibraryBloc>().add(const LibrarySelectionCleared()),
      ),
      title: AppText.titleLarge('$count'),
      actions: [
        IconButton(
          tooltip: 'library.select_all'.tr(),
          icon: const Icon(Icons.select_all),
          onPressed: () =>
              context.read<LibraryBloc>().add(const LibrarySelectAllToggled()),
        ),
        IconButton(
          tooltip: 'library.mark_read'.tr(),
          icon: const Icon(Icons.done_all),
          onPressed: () => context
              .read<LibraryBloc>()
              .add(const LibrarySelectedMarkedRead(true)),
        ),
        IconButton(
          tooltip: 'library.mark_unread'.tr(),
          icon: const Icon(Icons.remove_done),
          onPressed: () => context
              .read<LibraryBloc>()
              .add(const LibrarySelectedMarkedRead(false)),
        ),
        IconButton(
          tooltip: 'library.set_categories'.tr(),
          icon: const Icon(Icons.label_outline),
          onPressed: () => _pickCategories(context),
        ),
        IconButton(
          tooltip: 'library.remove'.tr(),
          icon: const Icon(Icons.delete_outline),
          onPressed: () =>
              context.read<LibraryBloc>().add(const LibrarySelectedRemoved()),
        ),
      ],
    );
  }

  void _pickCategories(BuildContext context) {
    final bloc = context.read<LibraryBloc>();
    _CategorySelectDialog.show(context, bloc.state.categories).then((picked) {
      if (picked != null) bloc.add(LibrarySelectedSetCategories(picked));
    });
  }
}

/// Checkbox picker over the existing categories; pops the chosen id list.
class _CategorySelectDialog extends StatelessWidget {
  const _CategorySelectDialog({required this.categories});

  final List<Category> categories;

  static Future<List<int>?> show(
    BuildContext context,
    List<Category> categories,
  ) {
    return showDialog<List<int>>(
      context: context,
      builder: (_) => _CategorySelectDialog(categories: categories),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const AppText.titleMedium('library.set_categories'),
      content: categories.isEmpty
          ? const AppText.bodyMedium('categories.empty')
          : _CategoryChecklist(categories: categories),
    );
  }
}

class _CategoryChecklist extends StatefulWidget {
  const _CategoryChecklist({required this.categories});

  final List<Category> categories;

  @override
  State<_CategoryChecklist> createState() => _CategoryChecklistState();
}

class _CategoryChecklistState extends State<_CategoryChecklist> {
  final ValueNotifier<Set<int>> _picked = ValueNotifier(const {});

  @override
  void dispose() {
    _picked.dispose();
    super.dispose();
  }

  void _toggle(int id, bool checked) {
    final next = Set<int>.from(_picked.value);
    checked ? next.add(id) : next.remove(id);
    _picked.value = next;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      child: ValueListenableBuilder<Set<int>>(
        valueListenable: _picked,
        builder: (context, picked, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.categories.map(
              (c) => CheckboxListTile(
                value: picked.contains(c.id),
                title: AppText.bodyMedium(c.name),
                onChanged: (v) => _toggle(c.id, v ?? false),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(picked.toList()),
                child: const AppText.labelLarge('common.ok'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
