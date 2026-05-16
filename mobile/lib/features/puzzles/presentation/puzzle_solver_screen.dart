import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/puzzle_controller.dart';
import '../data/puzzle_repository.dart';

class PuzzleSolverScreen extends ConsumerWidget {
  const PuzzleSolverScreen({required this.puzzleId, super.key});
  final String puzzleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleAsync = ref.watch(puzzleByIdProvider(puzzleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Solve')),
      body: puzzleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (puzzle) {
          if (puzzle == null) return const Center(child: Text('Not found'));
          final state = ref.watch(puzzleControllerProvider(puzzle));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('FEN: ${puzzle.fen}',
                    style: const TextStyle(fontFamily: 'monospace')),
                const SizedBox(height: 12),
                // TODO: Render the board with your chess-board package of choice
                // (e.g. flutter_chess_board / squares / wp_chessboard).
                //
                // Wire its onMove callback to:
                //   ref.read(puzzleControllerProvider(puzzle).notifier).tryMove(uci);
                //
                // The current chess.Chess instance lives at state.board, so you
                // can read state.board.fen for the current position.
                const Expanded(
                  child: Placeholder(child: Center(child: Text('Board here'))),
                ),
                const SizedBox(height: 12),
                Text('Status: ${state.status.name}'),
                Text('Progress: ${state.moveIndex} / ${puzzle.solution.length}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
