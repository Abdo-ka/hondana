import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/routing/app_router.gr.dart';
import 'package:hondana/features/browse/data/source/http_source_base.dart';
import 'package:hondana/features/browse/domain/source/source.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/features/browse/domain/source_preferences.dart';
import 'package:hondana/features/browse/presentation/bloc/extensions_bloc.dart';
import 'package:hondana/features/browse/presentation/widgets/extensions_body.dart';
import 'package:hondana/features/browse/presentation/widgets/source_url_dialog.dart';

/// Browse: Sources / Extensions tabs (Mihon layout), global search in the
/// app bar. Sources are grouped by language with pin support; pinned sources
/// float to a "Pinned" section on top.
@RoutePage()
class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => BlocProvider(
        create: (_) => getIt<ExtensionsBloc>()..add(const ExtensionsFetched()),
        child: const _BrowseView(),
      ),
    );
  }
}

class _BrowseView extends StatelessWidget {
  const _BrowseView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppAppBar(
          title: 'nav.browse',
          showDefaultBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.travel_explore),
              onPressed: () => context.router.push(GlobalSearchRoute()),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(child: AppText.labelLarge('browse.sources')),
              Tab(child: AppText.labelLarge('extensions.title')),
            ],
          ),
        ),
        body: const TabBarView(children: [_SourcesTab(), ExtensionsBody()]),
      ),
    );
  }
}

/// Sources tab: enabled sources grouped by language with pin support.
class _SourcesTab extends StatefulWidget {
  const _SourcesTab();

  @override
  State<_SourcesTab> createState() => _SourcesTabState();
}

class _SourcesTabState extends State<_SourcesTab> {
  final SourcePreferences _prefs = getIt<SourcePreferences>();

  /// Flips a source's pinned flag; the [ListenableBuilder] rebuilds the list.
  void _togglePin(int id) => _prefs.setPinned(id, !_prefs.isPinned(id));

  /// Enabled sources grouped: pinned first, then by language (local last).
  List<Widget> _sections(Set<int> pinned) {
    final enabled = getIt<SourceManager>()
        .getCatalogueSources()
        .where((s) => _prefs.isEnabled(s.id))
        .toList();
    final pinnedSources = enabled.where((s) => pinned.contains(s.id)).toList();
    const langOrder = ['all', 'en', 'ar', 'local'];
    return [
      if (pinnedSources.isNotEmpty) ...[
        const _LangHeader('browse.pinned'),
        ...pinnedSources.map(
          (s) => _SourceRow(source: s, pinned: true, onPin: _togglePin),
        ),
      ],
      ...langOrder.expand((lang) {
        final group = enabled.where((s) => s.lang == lang).toList();
        return group.isEmpty
            ? const <Widget>[]
            : <Widget>[
                _LangHeader('browse.lang_$lang'),
                ...group.map(
                  (s) => _SourceRow(
                    source: s,
                    pinned: pinned.contains(s.id),
                    onPin: _togglePin,
                  ),
                ),
              ];
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _prefs,
      builder: (context, _) => ListView(children: _sections(_prefs.pinnedIds)),
    );
  }
}

/// Section header labelling a language group (or the "Pinned" section).
class _LangHeader extends StatelessWidget {
  const _LangHeader(this.labelKey);

  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: AppText.titleSmall(labelKey, color: context.colorScheme.primary),
    );
  }
}

/// Mihon source row: icon, name, language; trailing "Latest" button + pin.
class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.source,
    required this.pinned,
    required this.onPin,
  });

  final CatalogueSource source;
  final bool pinned;
  final void Function(int id) onPin;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: AppText.titleMedium(source.name.substring(0, 1)),
      ),
      title: AppText.bodyLarge(source.name),
      subtitle: AppText.bodySmall(source.lang.toUpperCase()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (source.supportsLatest)
            TextButton(
              onPressed: () => context.router.push(
                SourceCatalogueRoute(
                  sourceId: source.id,
                  sourceName: source.name,
                  latest: true,
                ),
              ),
              child: const AppText.labelLarge('browse.latest'),
            ),
          IconButton(
            icon: Icon(
              pinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: pinned
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
            onPressed: () => onPin(source.id),
          ),
        ],
      ),
      onTap: () => context.router.push(
        SourceCatalogueRoute(sourceId: source.id, sourceName: source.name),
      ),
      // Long-press edits the source URL (sites hop domains frequently).
      onLongPress: source is HttpSourceBase
          ? () => showSourceUrlDialog(context, source as HttpSourceBase)
          : null,
    );
  }
}
