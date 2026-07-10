import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/extensions/context_ext.dart';
import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/core/widgets/feedback_indicators.dart';
import 'package:mihonx/features/browse/domain/extension_info.dart';
import 'package:mihonx/features/browse/domain/source/source.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/browse/domain/source_preferences.dart';
import 'package:mihonx/features/browse/presentation/bloc/extensions_bloc.dart';

/// Extensions content: search + built-in Dart sources (toggleable) + the full
/// keiyoushi catalog (ar/en/multi, 18+ filtered). Embedded in the Browse tab
/// and reachable standalone.
class ExtensionsBody extends StatelessWidget {
  const ExtensionsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: 'extensions.search_hint'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (q) =>
                context.read<ExtensionsBloc>().add(ExtensionsSearchChanged(q)),
          ),
        ),
        const _LangFilterChips(),
        const Expanded(child: _ExtensionsList()),
      ],
    );
  }
}

/// Language filter, Arabic surfaced first (the app's primary audience).
class _LangFilterChips extends StatelessWidget {
  const _LangFilterChips();

  static const _options = <(String?, String)>[
    (null, 'extensions.all_langs'),
    ('ar', 'browse.lang_ar'),
    ('en', 'browse.lang_en'),
    ('all', 'browse.lang_all'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExtensionsBloc, ExtensionsState>(
      buildWhen: (a, b) => a.langFilter != b.langFilter,
      builder: (context, state) => SizedBox(
        height: 40.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          children: [
            for (final (lang, label) in _options)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: AppText.labelMedium(label),
                  selected: state.langFilter == lang,
                  onSelected: (_) => context
                      .read<ExtensionsBloc>()
                      .add(ExtensionsLangChanged(lang)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExtensionsList extends StatelessWidget {
  const _ExtensionsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExtensionsBloc, ExtensionsState>(
      builder: (context, state) => ListView(
        children: [
          const _SectionHeader('extensions.built_in'),
          const _BuiltinSourcesSection(),
          const _SectionHeader('extensions.catalog'),
          ...state.loadStatus.isLoadingOrInitial
              ? const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: AppLoadingIndicator(),
                  ),
                ]
              : state.loadStatus.isFailure()
                  ? [
                      AppFailureIndicator(
                        message: 'extensions.load_failed'.tr(),
                        onRetry: () => context
                            .read<ExtensionsBloc>()
                            .add(const ExtensionsFetched()),
                        retryLabel: 'common.retry'.tr(),
                      ),
                    ]
                  : state.filtered
                      .map((e) => _CatalogTile(
                            info: e,
                            implemented: state.isImplemented(e),
                          ))
                      .toList(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: AppText.titleSmall(title, color: context.colorScheme.primary),
    );
  }
}

class _BuiltinSourcesSection extends StatefulWidget {
  const _BuiltinSourcesSection();

  @override
  State<_BuiltinSourcesSection> createState() => _BuiltinSourcesSectionState();
}

class _BuiltinSourcesSectionState extends State<_BuiltinSourcesSection> {
  final List<CatalogueSource> _sources =
      getIt<SourceManager>().getCatalogueSources();
  final SourcePreferences _prefs = getIt<SourcePreferences>();
  late final ValueNotifier<Set<int>> _disabled =
      ValueNotifier(_prefs.disabledIds);

  @override
  void dispose() {
    _disabled.dispose();
    super.dispose();
  }

  void _toggle(int id, bool enabled) {
    final next = Set<int>.from(_disabled.value);
    enabled ? next.remove(id) : next.add(id);
    _disabled.value = next;
    _prefs.setEnabled(id, enabled);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: _disabled,
      builder: (context, disabled, _) => Column(
        children: _sources
            .map(
              (s) => SwitchListTile(
                value: !disabled.contains(s.id),
                onChanged: (v) => _toggle(s.id, v),
                secondary: CircleAvatar(
                  child: AppText.titleMedium(s.name.substring(0, 1)),
                ),
                title: AppText.bodyLarge(s.name),
                subtitle: AppText.bodySmall(s.lang.toUpperCase()),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.info, required this.implemented});

  final ExtensionInfo info;
  final bool implemented;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 40.w,
        height: 40.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedNetworkImage(
            imageUrl: info.iconUrl,
            fit: BoxFit.cover,
            errorWidget: (context, _, _) => CircleAvatar(
              child: AppText.titleMedium(
                info.name.isEmpty ? '?' : info.name.substring(0, 1),
              ),
            ),
          ),
        ),
      ),
      title: AppText.bodyLarge(
        info.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: AppText.bodySmall(
        '${info.lang.toUpperCase()} • v${info.version}',
        color: context.colorScheme.onSurfaceVariant,
      ),
      trailing: implemented
          ? AppText.labelMedium(
              'extensions.installed',
              color: context.colorScheme.primary,
            )
          : AppText.labelMedium(
              'extensions.not_ported',
              color: context.colorScheme.outline,
            ),
      onTap: implemented
          ? null
          : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('extensions.not_ported_hint'.tr())),
              ),
    );
  }
}
