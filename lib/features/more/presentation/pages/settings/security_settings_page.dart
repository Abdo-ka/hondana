import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/features/more/domain/security_preferences.dart';
import 'package:mihonx/features/more/presentation/widgets/settings_widgets.dart';

@RoutePage()
class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PageLayoutBuilder(mobile: (context) => const _SecuritySettingsView());
}

class _SecuritySettingsView extends StatefulWidget {
  const _SecuritySettingsView();

  @override
  State<_SecuritySettingsView> createState() => _SecuritySettingsViewState();
}

class _SecuritySettingsViewState extends State<_SecuritySettingsView> {
  final SecurityPreferences _prefs = getIt<SecurityPreferences>();
  final LocalAuthentication _auth = LocalAuthentication();

  late final ValueNotifier<bool> _requireUnlock =
      ValueNotifier(_prefs.requireUnlock);
  late final ValueNotifier<int> _lockAfterMinutes =
      ValueNotifier(_prefs.lockAfterMinutes);
  late final ValueNotifier<bool> _hideNotificationContent =
      ValueNotifier(_prefs.hideNotificationContent);

  /// null while the capability check is still running.
  final ValueNotifier<bool?> _deviceSupported = ValueNotifier(null);

  /// Mihon: Always | 1 | 2 | 5 | 10 minutes | Never (0 / minutes / -1).
  static const List<int> _lockChoices = [0, 1, 2, 5, 10, -1];

  @override
  void initState() {
    super.initState();
    _auth.isDeviceSupported().then((supported) {
      if (mounted) _deviceSupported.value = supported;
    }).catchError((Object _) {
      if (mounted) _deviceSupported.value = false;
    });
  }

  @override
  void dispose() {
    _requireUnlock.dispose();
    _lockAfterMinutes.dispose();
    _hideNotificationContent.dispose();
    _deviceSupported.dispose();
    super.dispose();
  }

  static String _lockLabelKey(int minutes) => switch (minutes) {
        0 => 'settings.lock_always',
        -1 => 'settings.lock_never',
        _ => 'settings.lock_after_$minutes',
      };

  /// Mihon gates any change to these prefs behind a successful device auth.
  Future<bool> _authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'security.auth_reason'.tr(),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<void> _toggleRequireUnlock(bool value) async {
    if (!await _authenticate()) return;
    _requireUnlock.value = value;
    await _prefs.setRequireUnlock(value);
  }

  Future<void> _pickLockAfterMinutes() async {
    final picked = await OptionPickerSheet.show<int>(
      context,
      values: _lockChoices,
      selected: _lockAfterMinutes.value,
      labelKey: _lockLabelKey,
    );
    if (picked == null || picked == _lockAfterMinutes.value) return;
    if (!await _authenticate()) return;
    _lockAfterMinutes.value = picked;
    await _prefs.setLockAfterMinutes(picked);
  }

  Future<void> _toggleHideNotificationContent(bool value) async {
    _hideNotificationContent.value = value;
    await _prefs.setHideNotificationContent(value);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'settings.security'),
      body: ListView(
        children: [
          ValueListenableBuilder<bool?>(
            valueListenable: _deviceSupported,
            builder: (context, supported, _) => ValueListenableBuilder<bool>(
              valueListenable: _requireUnlock,
              builder: (context, requireUnlock, _) => SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const AppText.bodyLarge('settings.require_unlock'),
                subtitle: supported == false
                    ? AppText.bodySmall(
                        'settings.require_unlock_unsupported',
                        color: context.colorScheme.onSurfaceVariant,
                      )
                    : null,
                value: requireUnlock,
                onChanged: supported ?? false ? _toggleRequireUnlock : null,
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _requireUnlock,
            builder: (context, requireUnlock, _) =>
                ValueListenableBuilder<int>(
              valueListenable: _lockAfterMinutes,
              builder: (context, minutes, _) => ListTile(
                enabled: requireUnlock,
                leading: const Icon(Icons.timer_outlined),
                title: const AppText.bodyLarge('settings.lock_when_idle'),
                subtitle: AppText.bodySmall(
                  _lockLabelKey(minutes),
                  color: requireUnlock
                      ? context.colorScheme.onSurfaceVariant
                      : context.theme.disabledColor,
                ),
                onTap: _pickLockAfterMinutes,
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _hideNotificationContent,
            builder: (context, hide, _) => SwitchListTile(
              secondary: const Icon(Icons.visibility_off_outlined),
              title:
                  const AppText.bodyLarge('settings.hide_notification_content'),
              value: hide,
              onChanged: _toggleHideNotificationContent,
            ),
          ),
        ],
      ),
    );
  }
}
