import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/puzzles/presentation/puzzle_list_screen.dart';
import '../../features/puzzles/presentation/puzzle_solver_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
