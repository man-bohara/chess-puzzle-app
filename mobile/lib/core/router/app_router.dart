import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/puzzles/presentation/puzzle_list_screen.dart';
import '../../features/puzzles/presentation/puzzle_solver_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = auth.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';
      if (!isLoggedIn) return isLoggingIn ? null : '/login';
      if (isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (_, _) => const PuzzleListScreen(),
        routes: [
          GoRoute(
            path: 'puzzles/:id',
            builder: (_, state) =>
                PuzzleSolverScreen(puzzleId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
