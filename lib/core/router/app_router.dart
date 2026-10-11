import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_notifier.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/observatory/presentation/observatory_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/chat',
    routes: [
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/observatory',
        name: 'observatory',
        builder: (context, state) => const ObservatoryScreen(),
      ),
    ],
    redirect: (context, state) {
      final isGoingToAuth = state.matchedLocation == '/auth';

      // If user is not authenticated and not in mock mode
      if (!authState.isAuthenticated && !authState.isMockMode) {
        return isGoingToAuth ? null : '/auth';
      }

      // If already authenticated and trying to visit /auth
      if (authState.isAuthenticated && isGoingToAuth) {
        return '/chat';
      }

      return null;
    },
  );
});
