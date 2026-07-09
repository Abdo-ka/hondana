import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';

@RoutePage()
class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => const AppScaffold(
        appBar: AppAppBar(title: 'nav.browse', showDefaultBackButton: false),
        body: AppEmptyIndicator(
          message: 'browse.empty',
          icon: Icons.explore_outlined,
        ),
      ),
    );
  }
}
