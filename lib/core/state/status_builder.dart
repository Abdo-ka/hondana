import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/core/widgets/feedback_indicators.dart';

/// Rebuilds only when the selected [BlocStatus] changes. Preferred over raw
/// [BlocBuilder] for status-driven UI (per the badinan rules).
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

  final BlocStatus Function(S state) statusSelector;
  final WidgetBuilder onSuccess;
  final WidgetBuilder? onLoading;
  final WidgetBuilder? onEmpty;
  final String? emptyMessage;
  final WidgetBuilder? onInitial;
  final Widget Function(BuildContext context, AppException error)? onError;
  final VoidCallback? onRetry;
  final String? retryLabel;
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
