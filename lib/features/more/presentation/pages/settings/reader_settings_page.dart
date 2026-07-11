import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';

@RoutePage()
class ReaderSettingsPage extends StatelessWidget {
  const ReaderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => PageLayoutBuilder(
        mobile: (context) => const AppScaffold(
          appBar: AppAppBar(title: 'settings.reader'),
          body: SizedBox.shrink(),
        ),
      );
}
