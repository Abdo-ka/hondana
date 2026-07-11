import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hondana/core/error/app_exception.dart';
import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/core/widgets/feedback_indicators.dart';

/// Rebuilds only when the selected [BlocStatus] changes. Preferred over raw
/// [BlocBuilder] for status-driven UI.
class StatusBuilder<B extends BlocBase<S>, S> extends StatelessWidget {
  const StatusBuilder({
    required this.statusSelector,
    required this.onSuccess,
    this.onLoading,
    this.onEmpty,
    this.emptyMessage,
    this.onError,
    this.onInitial,
    this.onRetry,
    this.retryLabel,
    this.bloc,
    super.key,
  });

  /// Extracts the [BlocStatus] to watch from the bloc's state.
  final BlocStatus Function(S state) statusSelector;

  /// Required builder for the success branch.
  final WidgetBuilder onSuccess;

  /// Loading branch; falls back to [AppLoadingIndicator].
  final WidgetBuilder? onLoading;

  /// Empty branch; falls back to [AppEmptyIndicator] with [emptyMessage].
  final WidgetBuilder? onEmpty;

  /// Message shown by the default empty indicator when [onEmpty] is null.
  final String? emptyMessage;

  /// Initial branch; falls back to an empty box.
  final WidgetBuilder? onInitial;

  /// Failure branch; falls back to [AppFailureIndicator].
  final Widget Function(BuildContext context, AppException error)? onError;

  /// Retry callback wired into the default failure indicator.
  final VoidCallback? onRetry;

  /// Label for the default failure indicator's retry action.
  final String? retryLabel;

  /// Optional explicit bloc; when null the nearest provided one is used.
  final B? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<B, S, BlocStatus>(
      bloc: bloc,
      selector: statusSelector,
      builder: (context, status) {
        if (status.isSuccess()) return onSuccess(context);
        if (status.isLoading()) {
          return onLoading?.call(context) ?? const AppLoadingIndicator();
        }
        if (status.isEmpty()) {
          if (onEmpty != null) return onEmpty!(context);
          if (emptyMessage != null) {
            return AppEmptyIndicator(message: emptyMessage!);
          }
          return const SizedBox.shrink();
        }
        if (status.isInitial()) {
          return onInitial?.call(context) ?? const SizedBox.shrink();
        }
        final error = status.failureObjectForBuild;
        if (onError != null) return onError!(context, error);
        return AppFailureIndicator(
          message: error.message,
          onRetry: onRetry,
          retryLabel: retryLabel,
        );
      },
    );
  }
}
