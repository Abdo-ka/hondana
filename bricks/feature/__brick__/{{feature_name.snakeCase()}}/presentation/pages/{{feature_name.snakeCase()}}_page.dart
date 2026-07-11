import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/presentation/pages/mobile/{{feature_name.snakeCase()}}_page_mobile.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/presentation/state/bloc/{{feature_name.snakeCase()}}_bloc.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/presentation/state/bloc/{{feature_name.snakeCase()}}_event.dart';

/// Route wrapper for the {{feature_name.titleCase()}} feature.
///
/// Provides the [{{feature_name.pascalCase()}}Bloc] and delegates the responsive
/// layout to [{{feature_name.pascalCase()}}PageMobile] — no UI tree lives here.
@RoutePage()
class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<{{feature_name.pascalCase()}}Bloc>()..add(const {{feature_name.pascalCase()}}Started()),
      child: PageLayoutBuilder(
        mobile: (context) => const {{feature_name.pascalCase()}}PageMobile(),
      ),
    );
  }
}
