import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:hondana/features/updates/presentation/pages/mobile/updates_page_mobile.dart';
import 'package:hondana/features/updates/presentation/state/bloc/updates_bloc.dart';
import 'package:hondana/features/updates/presentation/state/bloc/updates_event.dart';

/// Updates tab route wrapper: provides [UpdatesBloc] (subscribing on mount)
/// alongside the shared [DownloadsBloc] used by per-row download buttons, then
/// delegates the layout to [UpdatesPageMobile].
@RoutePage()
class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<UpdatesBloc>()..add(const UpdatesSubscribed()),
        ),
        BlocProvider.value(value: getIt<DownloadsBloc>()),
      ],
      child: PageLayoutBuilder(mobile: (context) => const UpdatesPageMobile()),
    );
  }
}
