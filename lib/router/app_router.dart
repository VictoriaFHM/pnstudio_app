import 'package:go_router/go_router.dart';

import '../features/welcome/view/welcome_page.dart';
import '../features/advice/view/advice_page.dart';
import '../features/guide/view/view.dart';
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
        path: '/advice',
        name: 'advice',
        builder: (context, state) => const AdvicePage(),
      ),
      GoRoute(
        path: '/guide',
        name: 'guide',
        builder: (context, state) => const SectorGuidePage(),
      ),
      GoRoute(
        path: '/calc',
        name: 'calc',
        builder: (context, state) {
          // Support passing mode either via `extra` (old behavior) or via query parameter `mode`.
          InputMode mode = InputMode.basico;
          // First try query param `mode`
          final q = state.uri.queryParameters['mode'];
          if (q != null) {
            switch (q.toLowerCase()) {
              case 'percent':
              case 'porcentaje':
                mode = InputMode.porcentaje;
                break;
              case 'exact':
              case 'exacto':
                mode = InputMode.exacto;
                break;
              case 'basic':
              case 'basico':
                mode = InputMode.basico;
                break;
            }
          } else if (state.extra is InputMode) {
            mode = state.extra as InputMode;
          }

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
