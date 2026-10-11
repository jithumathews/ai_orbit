import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/orbit_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authRepo = AuthRepository();
  await authRepo.initialize();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
      ],
      child: const AiOrbitApp(),
    ),
  );
}

class AiOrbitApp extends ConsumerWidget {
  const AiOrbitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'AI Orbit — Multi-Model Planetary Gateway',
      debugShowCheckedModeBanner: false,
      theme: OrbitTheme.darkTheme,
      routerConfig: router,
    );
  }
}
