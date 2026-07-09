import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mihonx/core/extensions/context_ext.dart';
import 'package:mihonx/core/widgets/app_text.dart';

/// The one sanctioned spinner. Standalone [CircularProgressIndicator] is banned;
/// use this instead.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }
}

/// Empty state — icon + message, never a blank screen.
class AppEmptyIndicator extends StatelessWidget {
  const AppEmptyIndicator({required this.message, this.icon, super.key});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64.r,
              color: context.colorScheme.outline,
            ),
            SizedBox(height: 12.h),
            AppText.bodyMedium(
              message,
              textAlign: TextAlign.center,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Failure state with an optional retry action.
class AppFailureIndicator extends StatelessWidget {
  const AppFailureIndicator({
    required this.message,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.r,
              color: context.colorScheme.error,
            ),
            SizedBox(height: 12.h),
            AppText.bodyMedium(
              message,
              textAlign: TextAlign.center,
              color: context.colorScheme.onSurfaceVariant,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              FilledButton.tonal(
                onPressed: onRetry,
                child: AppText.labelLarge(retryLabel ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
