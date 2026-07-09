import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/utils/app_bloc_observer.dart';

/// Ordered startup invoked by `main()` before the first frame.
Future<void> preInitializations() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();
  Bloc.observer = const AppBlocObserver();
}
