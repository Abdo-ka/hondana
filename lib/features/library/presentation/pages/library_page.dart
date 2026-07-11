import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/library/presentation/bloc/library_bloc.dart';
import 'package:hondana/features/library/presentation/bloc/library_event.dart';
import 'package:hondana/features/library/presentation/bloc/library_state.dart';
import 'package:hondana/features/library/presentation/widgets/library_body.dart';
import 'package:hondana/features/library/presentation/widgets/library_options_sheet.dart';
import 'package:hondana/features/library/presentation/widgets/library_selection_app_bar.dart';

/// Library screen — the user's saved manga, with search, filters, and
/// multi-select. Hosts the grid/list body and swaps between the default and
/// selection app bars.
@RoutePage()
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => BlocProvider(
        create: (_) => getIt<LibraryBloc>()
          ..add(const LibraryCategoriesSubscribed())
          ..add(const LibrarySubscribed()),
        child: const _LibraryView(),
      ),
    );
  }
}

class _LibraryView extends StatefulWidget {
  const _LibraryView();

  @override
  State<_LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<_LibraryView> {
  final ValueNotifier<bool> _searching = ValueNotifier(false);
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searching.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _closeSearch(BuildContext context) {
    _searching.value = false;
    _searchController.clear();
    context.read<LibraryBloc>().add(const LibrarySearchChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (a, b) =>
          a.isSelecting != b.isSelecting ||
          a.selectedIds.length != b.selectedIds.length ||
          a.hasActiveFilters != b.hasActiveFilters,
      builder: (context, state) => AppScaffold(
        appBar: state.isSelecting
            ? LibrarySelectionAppBar(count: state.selectedIds.length)
            : _LibraryAppBar(
                searching: _searching,
                controller: _searchController,
                hasActiveFilters: state.hasActiveFilters,
                onCloseSearch: () => _closeSearch(context),
              ),
        body: const LibraryBody(),
      ),
    );
  }
}

/// Default app bar: "Library" title; search morphs the title into a text field;
/// filter icon shows a badge dot while filters are active (Mihon behavior).
class _LibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LibraryAppBar({
    required this.searching,
    required this.controller,
    required this.hasActiveFilters,
    required this.onCloseSearch,
  });

  final ValueNotifier<bool> searching;
  final TextEditingController controller;
  final bool hasActiveFilters;
  final VoidCallback onCloseSearch;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: searching,
      builder: (context, isSearching, _) => AppBar(
        automaticallyImplyLeading: false,
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onCloseSearch,
              )
            : null,
        title: isSearching
            ? TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'library.search_hint'.tr(),
                  border: InputBorder.none,
                ),
                onChanged: (q) =>
                    context.read<LibraryBloc>().add(LibrarySearchChanged(q)),
              )
            : const AppText.titleLarge('nav.library'),
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => searching.value = true,
            ),
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              smallSize: 8.r,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => LibraryOptionsSheet.show(context),
          ),
        ],
      ),
    );
  }
}
