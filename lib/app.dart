import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'router/app_router.dart';

class PnStudioApp extends StatelessWidget {
  const PnStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NP Studio',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
