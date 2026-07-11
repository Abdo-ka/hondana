import 'package:flutter/widgets.dart';
import 'package:hondana/core/error/app_exception.dart';
import 'package:hondana/core/widgets/feedback_indicators.dart';

/// Per-action status attached to a Bloc state field (one per async operation) —
/// the project's status pattern for status-driven UI.
enum Status { initial, loading, success, empty, failure }

/// Immutable status value plus the optional [AppException] for a failed op.
///
/// Wraps a [Status] so Bloc state can carry one status field per async
/// operation; equality is status-based (failures compare by message) so
/// selectors rebuild only on meaningful changes.
class BlocStatus {
  /// The current lifecycle phase of the operation.
  final Status status;

  /// The error captured when [status] is [Status.failure]; null otherwise.
  final AppException? failure;

  /// Not started yet.
  const BlocStatus.initial() : status = Status.initial, failure = null;

  /// Operation in flight.
  const BlocStatus.loading() : status = Status.loading, failure = null;

  /// Completed with data.
  const BlocStatus.success() : status = Status.success, failure = null;

  /// Completed but yielded no data.
  const BlocStatus.empty() : status = Status.empty, failure = null;

  /// Completed with the given [failure].
  const BlocStatus.failure(this.failure) : status = Status.failure;

  /// Whether the operation has not started.
  bool isInitial() => status == Status.initial;

  /// Whether the operation is in flight.
  bool isLoading() => status == Status.loading;

  /// Whether the operation completed with data.
  bool isSuccess() => status == Status.success;

  /// Whether the operation completed with no data.
  bool isEmpty() => status == Status.empty;

  /// Whether the operation failed.
  bool isFailure() => status == Status.failure;

  /// True while loading or not-yet-started — treats both as "no data to show".
  bool get isLoadingOrInitial =>
      status == Status.loading || status == Status.initial;

  /// The failure to render, falling back to a generic error if none was set.
  AppException get failureObjectForBuild =>
      failure ?? const AppException(message: 'Unknown error');

  /// Maps this status to a widget, defaulting to the shared feedback
  /// indicators; only [success] is required, other branches have sensible
  /// fallbacks.
  Widget build({
    Widget? initial,
    Widget? loading,
    required Widget Function() success,
    Widget? empty,
    String? emptyMessage,
    Widget Function(AppException failure)? failure,
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    switch (status) {
      case Status.initial:
        return initial ?? const SizedBox.shrink();
      case Status.loading:
        return loading ?? const AppLoadingIndicator();
      case Status.success:
        return success();
      case Status.empty:
        return empty ??
            (emptyMessage != null
                ? AppEmptyIndicator(message: emptyMessage)
                : const SizedBox.shrink());
      case Status.failure:
        final resolved = failureObjectForBuild;
        if (failure != null) return failure(resolved);
        return AppFailureIndicator(
          message: resolved.message,
          onRetry: onRetry,
          retryLabel: retryLabel,
        );
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlocStatus &&
        other.status == status &&
        (status != Status.failure ||
            other.failure?.message == failure?.message);
  }

  @override
  int get hashCode => status == Status.failure
      ? Object.hash(status, failure?.message)
      : status.hashCode;
}
