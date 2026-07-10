import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/reader/domain/reader_preferences.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_bloc.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_event.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_state.dart';

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
              children: ReadingMode.values
                  .map(
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
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

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
                              value: state.currentPage
                                  .toDouble()
                                  .clamp(0, (state.pageCount - 1).toDouble()),
                              max: (state.pageCount - 1).toDouble(),
                              onChanged: (v) => context
                                  .read<ReaderBloc>()
                                  .add(ReaderPageChanged(v.round())),
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
