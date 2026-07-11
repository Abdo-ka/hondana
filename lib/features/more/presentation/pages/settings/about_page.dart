import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/core.dart';

/// App version — mirrors pubspec.yaml (no package_info dependency).
/// Translation-exempt constant.
const String _appVersion = '0.1.0';

/// Upstream project this app is a port of. Display-only (no url_launcher dep).
const String _mihonRepoUrl = 'github.com/mihonapp/mihon';

@RoutePage()
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => PageLayoutBuilder(
        mobile: (context) => AppScaffold(
          appBar: const AppAppBar(title: 'settings.about'),
          body: ListView(
            children: [
              const _AppHeader(),
              const Divider(),
              ListTile(
                title: const AppText.bodyLarge('about.version'),
                subtitle: AppText.bodySmall(
                  _appVersion,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              ListTile(
                title: const AppText.bodyLarge('about.based_on_mihon'),
                subtitle: AppText.bodySmall(
                  _mihonRepoUrl,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              ListTile(
                title: const AppText.bodyLarge('about.open_source_licenses'),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'app_name'.tr(),
                  applicationVersion: _appVersion,
                ),
              ),
            ],
          ),
        ),
      );
}

/// App mark + name, mirroring the More tab header.
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          children: [
            Icon(
              Icons.collections_bookmark,
              size: 56.r,
              color: context.colorScheme.primary,
            ),
            SizedBox(height: 8.h),
            const AppText.titleLarge('app_name'),
          ],
        ),
      );
}
