import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';

@RoutePage()
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => const AppScaffold(
        appBar: AppAppBar(title: 'nav.more', showDefaultBackButton: false),
        body: AppEmptyIndicator(
          message: 'more.placeholder',
          icon: Icons.tune_outlined,
        ),
      ),
    );
  }
}
