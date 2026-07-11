import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/history/presentation/pages/mobile/history_page_mobile.dart';
import 'package:hondana/features/history/presentation/state/bloc/history_bloc.dart';
import 'package:hondana/features/history/presentation/state/bloc/history_event.dart';

/// Reading-history tab route wrapper: provides [HistoryBloc] and delegates the
/// responsive layout to [HistoryPageMobile]. No UI tree lives here.
@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HistoryBloc>()..add(const HistorySubscribed()),
      child: PageLayoutBuilder(mobile: (context) => const HistoryPageMobile()),
    );
  }
}
