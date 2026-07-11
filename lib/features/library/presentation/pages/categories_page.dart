import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/library/domain/category.dart';
import 'package:hondana/features/library/presentation/bloc/categories_bloc.dart';

/// Category management screen — create, rename, and delete user categories.
@RoutePage()
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => BlocProvider(
        create: (_) =>
            getIt<CategoriesBloc>()..add(const CategoriesSubscribed()),
        child: const _CategoriesView(),
      ),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'categories.title'),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _CategoryNameDialog.show(context, title: 'categories.add').then((
              name,
            ) {
              if (name != null && name.isNotEmpty && context.mounted) {
                context.read<CategoriesBloc>().add(CategoryCreated(name));
              }
            }),
        child: const Icon(Icons.add),
      ),
      body: StatusBuilder<CategoriesBloc, CategoriesState>(
        statusSelector: (s) => s.loadStatus,
        emptyMessage: 'categories.empty',
        onSuccess: (context) => const _CategoriesList(),
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  const _CategoriesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      buildWhen: (a, b) => a.categories != b.categories,
      builder: (context, state) => ListView.builder(
        itemCount: state.categories.length,
        itemBuilder: (context, index) =>
            _CategoryTile(category: state.categories[index]),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.label_outline),
      title: AppText.bodyLarge(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                _CategoryNameDialog.show(
                  context,
                  title: 'categories.rename',
                  initial: category.name,
                ).then((name) {
                  if (name != null && name.isNotEmpty && context.mounted) {
                    context.read<CategoriesBloc>().add(
                      CategoryRenamed(category.id, name),
                    );
                  }
                }),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => context.read<CategoriesBloc>().add(
              CategoryDeleted(category.id),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text-entry dialog for creating or renaming a category; pops the trimmed name.
class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({required this.title, this.initial});

  final String title;

  /// Pre-fills the field (rename); null for create.
  final String? initial;

  /// Opens the dialog and resolves to the entered name, or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? initial,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _CategoryNameDialog(title: title, initial: initial),
    );
  }

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppText.titleMedium(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'categories.name_hint'.tr(),
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const AppText.labelLarge('common.cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const AppText.labelLarge('common.ok'),
        ),
      ],
    );
  }
}
