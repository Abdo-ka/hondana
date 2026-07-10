import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/extensions/context_ext.dart';
import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_status.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/library/presentation/widgets/manga_cover.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_bloc.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_event.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_state.dart';

/// Mihon-style details header: the cover doubles as a faded backdrop behind
/// the info block; below it an action row, expandable description and genre
/// chips.
class MangaInfoHeader extends StatelessWidget {
  const MangaInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaDetailsBloc, MangaDetailsState>(
      builder: (context, state) => Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                _Backdrop(
                  url: state.thumbnailUrl,
                  sourceId: context.read<MangaDetailsBloc>().sourceId,
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 96.h, 16.w, 0),
                child: _InfoRow(state: state),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 0),
                child: _ActionRow(state: state),
              ),
              if ((state.manga?.description ?? '').isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: _ExpandableDescription(
                    description: state.manga?.description ?? '',
                    genres: state.manga?.genre ?? const [],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Cover art blown up behind the header, faded into the page background.
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.url, this.sourceId});

  final String? url;
  final int? sourceId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      width: context.width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MangaCover(url: url, sourceId: sourceId, radius: 0),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.colorScheme.surface.withValues(alpha: 0.55),
                  context.colorScheme.surface,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.state});

  final MangaDetailsState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 100.w,
          height: 150.h,
          child: MangaCover(
            url: state.thumbnailUrl,
            sourceId: context.read<MangaDetailsBloc>().sourceId,
            radius: 8,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.titleLarge(state.title, maxLines: 3),
              SizedBox(height: 6.h),
              if ((state.manga?.author ?? '').isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16.r,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: AppText.bodySmall(
                        state.manga?.author ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    switch (state.manga?.status ?? MangaStatus.unknown) {
                      MangaStatus.ongoing => Icons.schedule_outlined,
                      MangaStatus.completed => Icons.done_all,
                      MangaStatus.onHiatus => Icons.pause_circle_outline,
                      MangaStatus.cancelled => Icons.cancel_outlined,
                      _ => Icons.help_outline,
                    },
                    size: 16.r,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: AppText.bodySmall(
                      '${'status.${(state.manga?.status ?? MangaStatus.unknown).name}'.tr()} • ${getIt<SourceManager>().get(state.manga?.source ?? -1)?.name ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mihon's under-header action strip (tracking omitted — deferred feature).
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.state});

  final MangaDetailsState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: state.isFavorite ? Icons.favorite : Icons.favorite_border,
            label:
                state.isFavorite ? 'manga.in_library' : 'manga.add_to_library',
            active: state.isFavorite,
            onTap: () => context
                .read<MangaDetailsBloc>()
                .add(const MangaFavoriteToggled()),
          ),
        ),
        Expanded(
          child: _ActionButton(
            icon: Icons.refresh,
            label: 'manga.refresh',
            active: false,
            onTap: () => context
                .read<MangaDetailsBloc>()
                .add(const MangaChaptersRefreshed()),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: [
            Icon(
              icon,
              color: active
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 4.h),
            AppText.labelSmall(
              label,
              color: active
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsed 3-line description with a fade + chevron; genres are a single
/// scrollable row collapsed, wrapping when expanded (Mihon behavior).
class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({
    required this.description,
    required this.genres,
  });

  final String description;
  final List<String> genres;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  final ValueNotifier<bool> _expanded = ValueNotifier(false);

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _expanded,
      builder: (context, expanded, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _expanded.value = !expanded,
            child: Stack(
              children: [
                AppText.bodySmall(
                  widget.description,
                  maxLines: expanded ? null : 3,
                  overflow: expanded ? null : TextOverflow.fade,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                if (!expanded)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.colorScheme.surface.withValues(alpha: 0),
                            context.colorScheme.surface,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.expand_more,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (expanded)
            Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(
                  Icons.expand_less,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => _expanded.value = false,
              ),
            ),
          if (widget.genres.isNotEmpty) ...[
            SizedBox(height: 8.h),
            expanded
                ? Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: widget.genres
                        .map((g) => _GenreChip(label: g))
                        .toList(),
                  )
                : SizedBox(
                    height: 36.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: widget.genres
                          .map((g) => Padding(
                                padding: EdgeInsetsDirectional.only(end: 6.w),
                                child: _GenreChip(label: g),
                              ))
                          .toList(),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: AppText.labelSmall(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: context.colorScheme.outlineVariant),
    );
  }
}
