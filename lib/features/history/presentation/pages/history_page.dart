import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';

@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => const AppScaffold(
        appBar: AppAppBar(title: 'nav.history', showDefaultBackButton: false),
        body: AppEmptyIndicator(
          message: 'history.empty',
          icon: Icons.history_outlined,
        ),
      ),
    );
  }
}
