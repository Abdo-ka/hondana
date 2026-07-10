import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/routing/app_router.gr.dart';
import 'package:mihonx/features/browse/data/source/http_source_base.dart';
import 'package:mihonx/features/browse/domain/source/source.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/browse/presentation/bloc/source_catalogue_bloc.dart';
import 'package:mihonx/features/browse/presentation/bloc/source_catalogue_event.dart';
import 'package:mihonx/features/browse/presentation/bloc/source_catalogue_state.dart';
import 'package:mihonx/features/browse/presentation/widgets/source_manga_grid.dart';
import 'package:mihonx/features/browse/presentation/widgets/source_url_dialog.dart';

@RoutePage()
class SourceCataloguePage extends StatelessWidget {
  const SourceCataloguePage({
    required this.sourceId,
    this.sourceName,
    this.latest = false,
    super.key,
  });

  final int sourceId;
  final String? sourceName;

  /// Open directly on the Latest feed (Browse's "Latest" button).
  final bool latest;

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => BlocProvider(
        create: (_) => getIt<SourceCatalogueBloc>(param1: sourceId)
          ..add(latest
              ? const CatalogueModeChanged(CatalogueMode.latest)
              : const CatalogueStarted()),
        child: _CatalogueView(sourceId: sourceId, title: sourceName ?? ''),
      ),
    );
  }
}

class _CatalogueView extends StatelessWidget {
  const _CatalogueView({required this.sourceId, required this.title});

  final int sourceId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final source = getIt<SourceManager>().getCatalogueSource(sourceId);
    return AppScaffold(
      appBar: AppAppBar(
        title: title,
        actions: [
          if (source is HttpSourceBase)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final bloc = context.read<SourceCatalogueBloc>();
                final changed = await showSourceUrlDialog(context, source);
                if (changed == true && !bloc.isClosed) {
                  bloc.add(const CatalogueStarted());
                }
              },
            ),
          // WebView doubles as the Cloudflare-challenge solver: cookies it
          // earns are replayed onto this source's Dio requests.
          if (source is HttpSource)
            IconButton(
              icon: const Icon(Icons.public),
              onPressed: () => context.router.push(
                SourceWebViewRoute(initialUrl: source.baseUrl, title: title),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const _CatalogueControls(),
          Expanded(
            child: StatusBuilder<SourceCatalogueBloc, SourceCatalogueState>(
              statusSelector: (s) => s.loadStatus,
              emptyMessage: 'browse.no_results',
              onSuccess: (context) => _CatalogueGrid(sourceId: sourceId),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueControls extends StatelessWidget {
  const _CatalogueControls();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: 'browse.search_hint'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (q) => context
                .read<SourceCatalogueBloc>()
                .add(CatalogueSearched(q)),
          ),
          SizedBox(height: 8.h),
          BlocBuilder<SourceCatalogueBloc, SourceCatalogueState>(
            buildWhen: (a, b) => a.mode != b.mode,
            builder: (context, state) => SegmentedButton<CatalogueMode>(
              segments: const [
                ButtonSegment(
                  value: CatalogueMode.popular,
                  label: AppText.labelLarge('browse.popular'),
                ),
                ButtonSegment(
                  value: CatalogueMode.latest,
                  label: AppText.labelLarge('browse.latest'),
                ),
              ],
              selected: {
                state.mode == CatalogueMode.latest
                    ? CatalogueMode.latest
                    : CatalogueMode.popular,
              },
              onSelectionChanged: (s) => context
                  .read<SourceCatalogueBloc>()
                  .add(CatalogueModeChanged(s.first)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueGrid extends StatelessWidget {
  const _CatalogueGrid({required this.sourceId});

  final int sourceId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SourceCatalogueBloc, SourceCatalogueState>(
      buildWhen: (a, b) => a.manga != b.manga || a.hasNext != b.hasNext,
      builder: (context, state) => SourceMangaGrid(
        manga: state.manga,
        sourceId: sourceId,
        hasNext: state.hasNext,
        onLoadMore: () =>
            context.read<SourceCatalogueBloc>().add(const CatalogueLoadMore()),
      ),
    );
  }
}
