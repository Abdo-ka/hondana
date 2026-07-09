import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';

@RoutePage()
class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => const AppScaffold(
        appBar: AppAppBar(title: 'nav.updates', showDefaultBackButton: false),
        body: AppEmptyIndicator(
          message: 'updates.empty',
          icon: Icons.new_releases_outlined,
        ),
      ),
    );
  }
}
