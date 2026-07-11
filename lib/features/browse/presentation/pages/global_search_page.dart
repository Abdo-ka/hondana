import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/routing/app_router.gr.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/browse/domain/source/source.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/features/browse/presentation/bloc/global_search_bloc.dart';
import 'package:hondana/features/browse/presentation/bloc/global_search_event.dart';
import 'package:hondana/features/browse/presentation/bloc/global_search_state.dart';
import 'package:hondana/features/library/presentation/widgets/manga_cover.dart';

/// Searches every enabled source at once, showing one horizontal shelf per
/// source. Mihon behavior: sources are queried in parallel and results stream
/// in independently, so one slow/blocked source doesn't stall the rest.
@RoutePage()
class GlobalSearchPage extends StatelessWidget {
  const GlobalSearchPage({this.initialQuery, super.key});

  /// Prefilled query (e.g. opened from a manga's "search other sources").
  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => BlocProvider(
        create: (_) {
          final bloc = getIt<GlobalSearchBloc>();
          final q = initialQuery ?? '';
          if (q.isNotEmpty) bloc.add(GlobalSearched(q));
          return bloc;
        },
        child: _SearchView(initialQuery: initialQuery ?? ''),
      ),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView({required this.initialQuery});

  final String initialQuery;

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: widget.initialQuery.isEmpty,
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'search.hint'.tr(),
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (q) =>
              context.read<GlobalSearchBloc>().add(GlobalSearched(q)),
        ),
      ),
      body: BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
        builder: (context, state) => state.results.isEmpty
            ? Center(
                child: AppText.bodyMedium(
                  'search.hint',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : ListView.builder(
                itemCount: state.results.length,
                itemBuilder: (context, index) =>
                    _SourceSection(result: state.results[index]),
              ),
      ),
    );
  }
}

/// One source's results shelf: header + horizontal cover strip (or its
/// loading/empty/error state).
class _SourceSection extends StatelessWidget {
  const _SourceSection({required this.result});

  final SourceSearchResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
          child: AppText.titleSmall(result.sourceName),
        ),
        SizedBox(
          height: 190.h,
          child: result.status.build(
            loading: const AppLoadingIndicator(),
            emptyMessage: 'browse.no_results',
            failure: (failure) => _SourceError(
              sourceId: result.sourceId,
              sourceName: result.sourceName,
              message: failure.message,
            ),
            success: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              itemCount: result.manga.length,
              itemBuilder: (context, index) => _SearchCover(
                sourceId: result.sourceId,
                manga: result.manga[index],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact per-source failure row. Cloudflare-blocked sources (403) offer the
/// WebView so the user can pass the challenge; returning re-runs the search
/// with the earned cookies.
class _SourceError extends StatelessWidget {
  const _SourceError({
    required this.sourceId,
    required this.sourceName,
    required this.message,
  });

  final int sourceId;
  final String sourceName;
  final String message;

  @override
  Widget build(BuildContext context) {
    final source = getIt<SourceManager>().getCatalogueSource(sourceId);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.bodySmall(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              color: Theme.of(context).colorScheme.error,
            ),
            if (source is HttpSource)
              TextButton.icon(
                icon: const Icon(Icons.public),
                label: const AppText.labelLarge('browse.open_webview'),
                onPressed: () async {
                  final bloc = context.read<GlobalSearchBloc>();
                  await context.router.push(
                    SourceWebViewRoute(
                      initialUrl: source.baseUrl,
                      title: sourceName,
                    ),
                  );
                  if (!bloc.isClosed) {
                    bloc.add(GlobalSearched(bloc.state.query));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// A single manga cover + title in the horizontal shelf; taps into details.
class _SearchCover extends StatelessWidget {
  const _SearchCover({required this.sourceId, required this.manga});

  final int sourceId;
  final SManga manga;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.push(
        MangaDetailsRoute(sourceId: sourceId, initial: manga),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: SizedBox(
          width: 110.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MangaCover(url: manga.thumbnailUrl, sourceId: sourceId),
              ),
              SizedBox(height: 4.h),
              AppText.labelSmall(
                manga.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
