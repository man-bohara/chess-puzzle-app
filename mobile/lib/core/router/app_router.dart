import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/puzzles/presentation/puzzle_solver_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (state.matchedLocation == '/') return '/puzzle/0';
      return null;
    },
    routes: [
      GoRoute(
        path: '/puzzle/:index',
        builder: (_, state) {
          final index = int.tryParse(state.pathParameters['index'] ?? '0') ?? 0;
          return PuzzleSolverScreen(index: index);
        },
      ),
    ],
  );
});
