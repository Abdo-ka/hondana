import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/core.dart';

@RoutePage()
class DataStorageSettingsPage extends StatelessWidget {
  const DataStorageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => PageLayoutBuilder(
        mobile: (context) => const AppScaffold(
          appBar: AppAppBar(title: 'settings.data_storage'),
          body: SizedBox.shrink(),
        ),
      );
}
