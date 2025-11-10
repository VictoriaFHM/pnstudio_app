import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/welcome/view/welcome_page.dart';
import '../features/mode_select/view/mode_select_page.dart';
import '../features/calculator/view/calculator_page.dart';
import '../features/thanks/view/thanks_page.dart';
import '../features/mode_select/models/input_mode.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/mode',
        name: 'mode',
        builder: (context, state) => const ModeSelectPage(),
      ),
      GoRoute(
        path: '/calc',
        name: 'calc',
        builder: (context, state) {
          final mode = state.extra as InputMode? ?? InputMode.basico;
          return CalculatorPage(mode: mode);
        },
      ),
      GoRoute(
        path: '/thanks',
        name: 'thanks',
        builder: (context, state) => const ThanksPage(),
      ),
    ],
  );
}
