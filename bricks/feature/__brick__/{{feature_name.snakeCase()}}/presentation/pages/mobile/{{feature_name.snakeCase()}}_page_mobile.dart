import 'package:flutter/material.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/presentation/state/bloc/{{feature_name.snakeCase()}}_bloc.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/presentation/state/bloc/{{feature_name.snakeCase()}}_state.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/presentation/widgets/{{feature_name.snakeCase()}}_widget.dart';

/// Mobile layout for the {{feature_name.titleCase()}} feature — the actual screen
/// tree. Renders load/empty/failure via [StatusBuilder].
class {{feature_name.pascalCase()}}PageMobile extends StatelessWidget {
  const {{feature_name.pascalCase()}}PageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: '{{feature_name.snakeCase()}}.title'),
      body: StatusBuilder<{{feature_name.pascalCase()}}Bloc, {{feature_name.pascalCase()}}State>(
        statusSelector: (state) => state.loadStatus,
        emptyMessage: '{{feature_name.snakeCase()}}.empty',
        onSuccess: (context) => const {{feature_name.pascalCase()}}Widget(),
      ),
    );
  }
}
