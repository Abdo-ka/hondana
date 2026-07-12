import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/features/main/presentation/pages/mobile/main_page_mobile.dart';

/// Bottom-nav shell route wrapper hosting the five primary tabs. Delegates the
/// layout to [MainPageMobile]; no UI tree lives here.
@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(mobile: (context) => const MainPageMobile());
  }
}
