import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hondana/core/widgets/app_text.dart';
import 'package:hondana/features/reader/domain/reader_preferences.dart';
import 'package:hondana/features/reader/presentation/bloc/reader_bloc.dart';
import 'package:hondana/features/reader/presentation/bloc/reader_event.dart';
import 'package:hondana/features/reader/presentation/bloc/reader_state.dart';

/// Reader menu top bar: back button, chapter title, and the mode/settings
/// button that opens the per-series reading-mode sheet.
class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ColoredBox(
        color: Colors.black54,
        child: SafeArea(
          bottom: false,
          child: BlocBuilder<ReaderBloc, ReaderState>(
            buildWhen: (a, b) => a.chapterName != b.chapterName,
            builder: (context, state) => Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.router.maybePop(),
                ),
                Expanded(
                  child: AppText.bodyLarge(
                    state.chapterName,
                    color: Colors.white,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onPressed: () => _showModeSheet(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mihon "For this series" sheet: pick a per-series reading mode, or Default
  /// to fall back to the app-wide mode.
  void _showModeSheet(BuildContext context) {
    final bloc = context.read<ReaderBloc>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<ReaderBloc, ReaderState>(
          buildWhen: (a, b) => a.readingMode != b.readingMode,
          builder: (context, state) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Per-series override (Mihon "For this series"); Default
                // reverts to the app-wide mode from Settings > Reader.
                ListTile(
                  title: const AppText.bodyMedium('reader.mode_default'),
                  onTap: () => context.read<ReaderBloc>().add(
                    const ReaderModeChanged(null),
                  ),
                ),
                ...ReadingMode.values.map(
                  (m) => ListTile(
                    title: AppText.bodyMedium('reader.mode_${m.name}'),
                    trailing: state.readingMode == m
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () =>
                        context.read<ReaderBloc>().add(ReaderModeChanged(m)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reader menu bottom bar: prev/next-chapter buttons flanking the page
/// seekbar. Direction and button semantics flip in right-to-left mode.
class ReaderBottomBar extends StatelessWidget {
  const ReaderBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ColoredBox(
        color: Colors.black54,
        child: SafeArea(
          top: false,
          child: BlocBuilder<ReaderBloc, ReaderState>(
            buildWhen: (a, b) =>
                a.currentPage != b.currentPage ||
                a.pageCount != b.pageCount ||
                a.readingMode != b.readingMode ||
                a.hasPrev != b.hasPrev ||
                a.hasNext != b.hasNext,
            builder: (context, state) {
              // In right-to-left mode reading advances leftwards: the seekbar
              // runs right-to-left and the chapter buttons swap semantics
              // (Mihon behavior).
              final reversed = state.readingMode.isReversed;
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: (reversed ? state.hasNext : state.hasPrev)
                        ? () => context.read<ReaderBloc>().add(
                            reversed
                                ? const ReaderNextChapter()
                                : const ReaderPrevChapter(),
                          )
                        : null,
                  ),
                  Expanded(
                    child: state.pageCount > 1
                        ? Directionality(
                            textDirection: reversed
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Slider(
                              value: state.currentPage.toDouble().clamp(
                                0,
                                (state.pageCount - 1).toDouble(),
                              ),
                              max: (state.pageCount - 1).toDouble(),
                              onChanged: (v) => context.read<ReaderBloc>().add(
                                ReaderPageChanged(v.round()),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  AppText.labelMedium(
                    '${state.currentPage + 1}/${state.pageCount}',
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: (reversed ? state.hasPrev : state.hasNext)
                        ? () => context.read<ReaderBloc>().add(
                            reversed
                                ? const ReaderPrevChapter()
                                : const ReaderNextChapter(),
                          )
                        : null,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
