import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/features/browse/presentation/bloc/extensions_bloc.dart';
import 'package:mihonx/features/browse/presentation/widgets/extensions_body.dart';

/// Standalone Extensions screen (the same content is embedded as a Browse tab).
@RoutePage()
class ExtensionsPage extends StatelessWidget {
  const ExtensionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => BlocProvider(
        create: (_) => getIt<ExtensionsBloc>()..add(const ExtensionsFetched()),
        child: const AppScaffold(
          appBar: AppAppBar(title: 'extensions.title'),
          body: ExtensionsBody(),
        ),
      ),
    );
  }
}
