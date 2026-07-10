// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i16;
import 'package:flutter/material.dart' as _i17;
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart'
    as _i18;
import 'package:mihonx/features/browse/presentation/pages/browse_page.dart'
    as _i1;
import 'package:mihonx/features/browse/presentation/pages/extensions_page.dart'
    as _i4;
import 'package:mihonx/features/browse/presentation/pages/global_search_page.dart'
    as _i5;
import 'package:mihonx/features/browse/presentation/pages/source_catalogue_page.dart'
    as _i13;
import 'package:mihonx/features/browse/presentation/pages/source_webview_page.dart'
    as _i14;
import 'package:mihonx/features/downloads/presentation/pages/downloads_page.dart'
    as _i3;
import 'package:mihonx/features/history/presentation/pages/history_page.dart'
    as _i6;
import 'package:mihonx/features/library/presentation/pages/categories_page.dart'
    as _i2;
import 'package:mihonx/features/library/presentation/pages/library_page.dart'
    as _i7;
import 'package:mihonx/features/main/presentation/pages/main_page.dart' as _i8;
import 'package:mihonx/features/manga/presentation/pages/manga_details_page.dart'
    as _i9;
import 'package:mihonx/features/more/presentation/pages/more_page.dart' as _i10;
import 'package:mihonx/features/more/presentation/pages/settings_page.dart'
    as _i12;
import 'package:mihonx/features/reader/presentation/pages/reader_page.dart'
    as _i11;
import 'package:mihonx/features/updates/presentation/pages/updates_page.dart'
    as _i15;

/// generated route for
/// [_i1.BrowsePage]
class BrowseRoute extends _i16.PageRouteInfo<void> {
  const BrowseRoute({List<_i16.PageRouteInfo>? children})
    : super(BrowseRoute.name, initialChildren: children);

  static const String name = 'BrowseRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i1.BrowsePage();
    },
  );
}

/// generated route for
/// [_i2.CategoriesPage]
class CategoriesRoute extends _i16.PageRouteInfo<void> {
  const CategoriesRoute({List<_i16.PageRouteInfo>? children})
    : super(CategoriesRoute.name, initialChildren: children);

  static const String name = 'CategoriesRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i2.CategoriesPage();
    },
  );
}

/// generated route for
/// [_i3.DownloadsPage]
class DownloadsRoute extends _i16.PageRouteInfo<void> {
  const DownloadsRoute({List<_i16.PageRouteInfo>? children})
    : super(DownloadsRoute.name, initialChildren: children);

  static const String name = 'DownloadsRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i3.DownloadsPage();
    },
  );
}

/// generated route for
/// [_i4.ExtensionsPage]
class ExtensionsRoute extends _i16.PageRouteInfo<void> {
  const ExtensionsRoute({List<_i16.PageRouteInfo>? children})
    : super(ExtensionsRoute.name, initialChildren: children);

  static const String name = 'ExtensionsRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i4.ExtensionsPage();
    },
  );
}

/// generated route for
/// [_i5.GlobalSearchPage]
class GlobalSearchRoute extends _i16.PageRouteInfo<GlobalSearchRouteArgs> {
  GlobalSearchRoute({
    String? initialQuery,
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
         GlobalSearchRoute.name,
         args: GlobalSearchRouteArgs(initialQuery: initialQuery, key: key),
         initialChildren: children,
       );

  static const String name = 'GlobalSearchRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GlobalSearchRouteArgs>(
        orElse: () => const GlobalSearchRouteArgs(),
      );
      return _i5.GlobalSearchPage(
        initialQuery: args.initialQuery,
        key: args.key,
      );
    },
  );
}

class GlobalSearchRouteArgs {
  const GlobalSearchRouteArgs({this.initialQuery, this.key});

  final String? initialQuery;

  final _i17.Key? key;

  @override
  String toString() {
    return 'GlobalSearchRouteArgs{initialQuery: $initialQuery, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GlobalSearchRouteArgs) return false;
    return initialQuery == other.initialQuery && key == other.key;
  }

  @override
  int get hashCode => initialQuery.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i6.HistoryPage]
class HistoryRoute extends _i16.PageRouteInfo<void> {
  const HistoryRoute({List<_i16.PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i6.HistoryPage();
    },
  );
}

/// generated route for
/// [_i7.LibraryPage]
class LibraryRoute extends _i16.PageRouteInfo<void> {
  const LibraryRoute({List<_i16.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i7.LibraryPage();
    },
  );
}

/// generated route for
/// [_i8.MainPage]
class MainRoute extends _i16.PageRouteInfo<void> {
  const MainRoute({List<_i16.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i8.MainPage();
    },
  );
}

/// generated route for
/// [_i9.MangaDetailsPage]
class MangaDetailsRoute extends _i16.PageRouteInfo<MangaDetailsRouteArgs> {
  MangaDetailsRoute({
    required int sourceId,
    required _i18.SManga initial,
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
         MangaDetailsRoute.name,
         args: MangaDetailsRouteArgs(
           sourceId: sourceId,
           initial: initial,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'MangaDetailsRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MangaDetailsRouteArgs>();
      return _i9.MangaDetailsPage(
        sourceId: args.sourceId,
        initial: args.initial,
        key: args.key,
      );
    },
  );
}

class MangaDetailsRouteArgs {
  const MangaDetailsRouteArgs({
    required this.sourceId,
    required this.initial,
    this.key,
  });

  final int sourceId;

  final _i18.SManga initial;

  final _i17.Key? key;

  @override
  String toString() {
    return 'MangaDetailsRouteArgs{sourceId: $sourceId, initial: $initial, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MangaDetailsRouteArgs) return false;
    return sourceId == other.sourceId &&
        initial == other.initial &&
        key == other.key;
  }

  @override
  int get hashCode => sourceId.hashCode ^ initial.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i10.MorePage]
class MoreRoute extends _i16.PageRouteInfo<void> {
  const MoreRoute({List<_i16.PageRouteInfo>? children})
    : super(MoreRoute.name, initialChildren: children);

  static const String name = 'MoreRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i10.MorePage();
    },
  );
}

/// generated route for
/// [_i11.ReaderPage]
class ReaderRoute extends _i16.PageRouteInfo<ReaderRouteArgs> {
  ReaderRoute({
    required int chapterId,
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
         ReaderRoute.name,
         args: ReaderRouteArgs(chapterId: chapterId, key: key),
         initialChildren: children,
       );

  static const String name = 'ReaderRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReaderRouteArgs>();
      return _i11.ReaderPage(chapterId: args.chapterId, key: args.key);
    },
  );
}

class ReaderRouteArgs {
  const ReaderRouteArgs({required this.chapterId, this.key});

  final int chapterId;

  final _i17.Key? key;

  @override
  String toString() {
    return 'ReaderRouteArgs{chapterId: $chapterId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReaderRouteArgs) return false;
    return chapterId == other.chapterId && key == other.key;
  }

  @override
  int get hashCode => chapterId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i12.SettingsPage]
class SettingsRoute extends _i16.PageRouteInfo<void> {
  const SettingsRoute({List<_i16.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i12.SettingsPage();
    },
  );
}

/// generated route for
/// [_i13.SourceCataloguePage]
class SourceCatalogueRoute
    extends _i16.PageRouteInfo<SourceCatalogueRouteArgs> {
  SourceCatalogueRoute({
    required int sourceId,
    String? sourceName,
    bool latest = false,
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
         SourceCatalogueRoute.name,
         args: SourceCatalogueRouteArgs(
           sourceId: sourceId,
           sourceName: sourceName,
           latest: latest,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'SourceCatalogueRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SourceCatalogueRouteArgs>();
      return _i13.SourceCataloguePage(
        sourceId: args.sourceId,
        sourceName: args.sourceName,
        latest: args.latest,
        key: args.key,
      );
    },
  );
}

class SourceCatalogueRouteArgs {
  const SourceCatalogueRouteArgs({
    required this.sourceId,
    this.sourceName,
    this.latest = false,
    this.key,
  });

  final int sourceId;

  final String? sourceName;

  final bool latest;

  final _i17.Key? key;

  @override
  String toString() {
    return 'SourceCatalogueRouteArgs{sourceId: $sourceId, sourceName: $sourceName, latest: $latest, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SourceCatalogueRouteArgs) return false;
    return sourceId == other.sourceId &&
        sourceName == other.sourceName &&
        latest == other.latest &&
        key == other.key;
  }

  @override
  int get hashCode =>
      sourceId.hashCode ^ sourceName.hashCode ^ latest.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i14.SourceWebViewPage]
class SourceWebViewRoute extends _i16.PageRouteInfo<SourceWebViewRouteArgs> {
  SourceWebViewRoute({
    required String initialUrl,
    String? title,
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
         SourceWebViewRoute.name,
         args: SourceWebViewRouteArgs(
           initialUrl: initialUrl,
           title: title,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'SourceWebViewRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SourceWebViewRouteArgs>();
      return _i14.SourceWebViewPage(
        initialUrl: args.initialUrl,
        title: args.title,
        key: args.key,
      );
    },
  );
}

class SourceWebViewRouteArgs {
  const SourceWebViewRouteArgs({
    required this.initialUrl,
    this.title,
    this.key,
  });

  final String initialUrl;

  final String? title;

  final _i17.Key? key;

  @override
  String toString() {
    return 'SourceWebViewRouteArgs{initialUrl: $initialUrl, title: $title, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SourceWebViewRouteArgs) return false;
    return initialUrl == other.initialUrl &&
        title == other.title &&
        key == other.key;
  }

  @override
  int get hashCode => initialUrl.hashCode ^ title.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i15.UpdatesPage]
class UpdatesRoute extends _i16.PageRouteInfo<void> {
  const UpdatesRoute({List<_i16.PageRouteInfo>? children})
    : super(UpdatesRoute.name, initialChildren: children);

  static const String name = 'UpdatesRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i15.UpdatesPage();
    },
  );
}
