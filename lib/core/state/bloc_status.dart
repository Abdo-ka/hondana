import 'package:flutter/widgets.dart';
import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/widgets/feedback_indicators.dart';

/// Per-action status attached to a Bloc state field (one per async operation),
/// exactly as the badinan rules prescribe.
enum Status { initial, loading, success, empty, failure }

class BlocStatus {
  final Status status;
  final AppException? failure;

  const BlocStatus.initial() : status = Status.initial, failure = null;
  const BlocStatus.loading() : status = Status.loading, failure = null;
  const BlocStatus.success() : status = Status.success, failure = null;
  const BlocStatus.empty() : status = Status.empty, failure = null;
  const BlocStatus.failure(this.failure) : status = Status.failure;

  bool isInitial() => status == Status.initial;
  bool isLoading() => status == Status.loading;
  bool isSuccess() => status == Status.success;
  bool isEmpty() => status == Status.empty;
  bool isFailure() => status == Status.failure;
  bool get isLoadingOrInitial =>
      status == Status.loading || status == Status.initial;

  AppException get failureObjectForBuild =>
      failure ?? const AppException(message: 'Unknown error');

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
