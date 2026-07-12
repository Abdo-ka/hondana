import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:hondana/features/manga/presentation/pages/mobile/manga_details_page_mobile.dart';
import 'package:hondana/features/manga/presentation/state/bloc/manga_details_bloc.dart';
import 'package:hondana/features/manga/presentation/state/bloc/manga_details_event.dart';

/// Manga details route wrapper: provides [MangaDetailsBloc] (seeded with the
/// source id + initial [SManga]) and the shared [DownloadsBloc], then delegates
/// the layout to [MangaDetailsPageMobile].
@RoutePage()
class MangaDetailsPage extends StatelessWidget {
  const MangaDetailsPage({
    required this.sourceId,
    required this.initial,
    super.key,
  });

  final int sourceId;
  final SManga initial;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<MangaDetailsBloc>(param1: sourceId, param2: initial)
                ..add(const MangaDetailsStarted()),
        ),
        BlocProvider.value(value: getIt<DownloadsBloc>()),
      ],
      child: PageLayoutBuilder(
        mobile: (context) => const MangaDetailsPageMobile(),
      ),
    );
  }
}
