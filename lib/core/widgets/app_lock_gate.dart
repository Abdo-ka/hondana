import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/more/domain/security_preferences.dart';

/// Gates the whole app behind Face ID / Touch ID / passcode when
/// Settings > Security > "Require unlock" is on, re-locking after the
/// configured idle time in background (0 = always, -1 = never).
class AppLockGate extends StatefulWidget {
  const AppLockGate({required this.child, super.key});

  /// The app subtree hidden and gated behind unlock.
  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final SecurityPreferences _prefs = getIt<SecurityPreferences>();
  final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the lock scrim is currently shown. Starts locked if the pref is on.
  late final ValueNotifier<bool> _locked = ValueNotifier(_prefs.requireUnlock);

  /// When the app last went to background (paused), for the idle re-lock.
  DateTime? _backgroundedAt;

  /// Guards against overlapping authenticate() calls.
  bool _authInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_locked.value) {
      // Auto-prompt on first show, once the first frame is up.
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locked.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  /// On resume, re-locks if the idle threshold elapsed, then prompts to unlock.
  void _onResumed() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (_prefs.requireUnlock && !_locked.value && backgroundedAt != null) {
      final lockAfterMinutes = _prefs.lockAfterMinutes;
      final elapsed = DateTime.now().difference(backgroundedAt);
      final shouldRelock =
          lockAfterMinutes == 0 ||
          (lockAfterMinutes > 0 &&
              elapsed >= Duration(minutes: lockAfterMinutes));
      if (shouldRelock) _locked.value = true;
    }
    if (_locked.value) _tryUnlock();
  }

  /// Prompts the platform biometric/passcode sheet and unlocks on success.
  Future<void> _tryUnlock() async {
    if (_authInProgress || !_locked.value) return;
    _authInProgress = true;
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'security.auth_reason'.tr(),
      );
      if (ok) _locked.value = false;
    } on PlatformException {
      // Cancelled / unavailable — stay locked; the retry button remains.
    } finally {
      _authInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _locked,
      builder: (context, locked, child) => Stack(
        fit: StackFit.expand,
        children: [
          if (child != null) ExcludeSemantics(excluding: locked, child: child),
          if (locked) _LockScreen(onUnlock: _tryUnlock),
        ],
      ),
      child: widget.child,
    );
  }
}

/// Opaque, app-branded scrim shown while the app is locked.
class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});

  /// Invoked by the retry button to re-trigger the auth prompt.
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64.r,
                color: context.colorScheme.primary,
              ),
              SizedBox(height: 16.h),
              const AppText.headlineSmall('app_name'),
              SizedBox(height: 8.h),
              AppText.bodyMedium(
                'security.locked',
                color: context.colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: 24.h),
              FilledButton.icon(
                onPressed: onUnlock,
                icon: const Icon(Icons.lock_open_outlined),
                label: AppText.labelLarge(
                  'security.unlock',
                  color: context.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
