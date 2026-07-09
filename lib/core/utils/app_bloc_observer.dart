import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Logs bloc lifecycle + errors in debug. Wired via `Bloc.observer`.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[Bloc] ${bloc.runtimeType} error: $error');
    }
    super.onError(bloc, error, stackTrace);
  }
}
