import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:pnstudio_app/features/welcome/view/welcome_page.dart';
import 'package:pnstudio_app/features/mode_select/view/mode_select_page.dart';
import 'package:pnstudio_app/features/mode_select/models/input_mode.dart';
import 'package:pnstudio_app/features/calculator/view/calculator_page.dart';
import 'package:pnstudio_app/features/thanks/view/thanks_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const WelcomePage()),
      GoRoute(path: '/mode', builder: (_, __) => const ModeSelectPage()),
      GoRoute(
        path: '/calc',
        builder: (_, state) =>
            CalculatorPage(mode: state.extra as InputMode? ?? InputMode.basico),
      ),
      GoRoute(path: '/thanks', builder: (_, __) => const ThanksPage()),
    ],
  );
}
