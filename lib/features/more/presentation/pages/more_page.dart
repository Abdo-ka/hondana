import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/config/app_settings.dart';
import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/routing/app_router.gr.dart';

/// More tab, Mihon layout: app mark header, the two global switches
/// (Downloaded only / Incognito — both functional), then navigation rows.
@RoutePage()
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => AppScaffold(
        appBar: const AppAppBar(
          title: 'nav.more',
          showDefaultBackButton: false,
        ),
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Icon(
                Icons.collections_bookmark,
                size: 56.r,
                color: context.colorScheme.primary,
              ),
            ),
            const Divider(),
            const _DownloadedOnlySwitch(),
            const _IncognitoSwitch(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const AppText.bodyLarge('more.downloads'),
              onTap: () => context.router.push(const DownloadsRoute()),
            ),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const AppText.bodyLarge('more.categories'),
              onTap: () => context.router.push(const CategoriesRoute()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const AppText.bodyLarge('more.settings'),
              onTap: () => context.router.push(const SettingsRoute()),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const AppText.bodyLarge('settings.about'),
              onTap: () => context.router.push(const AboutRoute()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Global "Downloaded only" toggle — restricts library/browse to local files.
/// Bound to [AppSettings.downloadedOnlyNotifier] so every surface stays in sync.
class _DownloadedOnlySwitch extends StatelessWidget {
  const _DownloadedOnlySwitch();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: getIt<AppSettings>().downloadedOnlyNotifier,
      builder: (context, value, _) => SwitchListTile(
        value: value,
        onChanged: (v) => getIt<AppSettings>().setDownloadedOnly(v),
        secondary: const Icon(Icons.cloud_off_outlined),
        title: const AppText.bodyLarge('more.downloaded_only'),
        subtitle: const AppText.bodySmall('more.downloaded_only_hint'),
      ),
    );
  }
}

/// Global "Incognito" toggle — suppresses history/tracking while browsing.
/// Bound to [AppSettings.incognitoNotifier].
class _IncognitoSwitch extends StatelessWidget {
  const _IncognitoSwitch();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: getIt<AppSettings>().incognitoNotifier,
      builder: (context, value, _) => SwitchListTile(
        value: value,
        onChanged: (v) => getIt<AppSettings>().setIncognito(v),
        secondary: const Icon(Icons.visibility_off_outlined),
        title: const AppText.bodyLarge('more.incognito'),
        subtitle: const AppText.bodySmall('more.incognito_hint'),
      ),
    );
  }
}
