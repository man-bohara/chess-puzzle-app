import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';

import '../application/puzzle_controller.dart';
import '../data/puzzle_repository.dart';
import '../domain/puzzle.dart';

class PuzzleSolverScreen extends ConsumerWidget {
  const PuzzleSolverScreen({required this.index, super.key});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleAsync = ref.watch(puzzleByIndexProvider(index));
    final totalAsync = ref.watch(puzzleCountProvider);
    final total = totalAsync.valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(total > 0 ? 'Puzzle ${index + 1} of $total' : 'Puzzle'),
      ),
      body: puzzleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (puzzle) {
          if (puzzle == null) return const Center(child: Text('Not found'));
          return _PuzzleBoard(
            puzzle: puzzle,
            index: index,
            isLast: total > 0 && index >= total - 1,
          );
        },
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.status,
    required this.moveIndex,
    required this.totalMoves,
    required this.lastWasWrong,
  });
  final PuzzleStatus status;
  final int moveIndex;
  final int totalMoves;
  final bool lastWasWrong;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, label) = switch (status) {
      PuzzleStatus.solved => (
          Colors.green.shade600,
          Colors.white,
          Icons.celebration,
          'Solved!',
        ),
      PuzzleStatus.inProgress when lastWasWrong => (
          Colors.red.shade600,
          Colors.white,
          Icons.cancel,
          'Wrong move — try again',
        ),
      PuzzleStatus.inProgress => (
          Theme.of(context).colorScheme.surfaceContainerHighest,
          Theme.of(context).colorScheme.onSurfaceVariant,
          Icons.timeline,
          'Progress $moveIndex / $totalMoves',
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PuzzleBoard extends ConsumerStatefulWidget {
  const _PuzzleBoard({
    required this.puzzle,
    required this.index,
    required this.isLast,
  });
  final Puzzle puzzle;
  final int index;
  final bool isLast;

  @override
  ConsumerState<_PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends ConsumerState<_PuzzleBoard> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = widget.puzzle;

    ref.listen<PuzzleAttemptState>(
      puzzleControllerProvider(puzzle),
      (prev, next) {
        if (prev?.status != PuzzleStatus.solved &&
            next.status == PuzzleStatus.solved) {
          _confetti.play();
        }
      },
    );

    final state = ref.watch(puzzleControllerProvider(puzzle));
    final orientation =
        puzzle.fen.split(' ')[1] == 'b' ? Squares.black : Squares.white;
    final squaresState = state.game.squaresState(orientation);
    final whiteToMove = orientation == Squares.white;
    final solved = state.status == PuzzleStatus.solved;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (puzzle.themes.isNotEmpty) ...[
            Text(
              puzzle.themes.join(' · '),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: whiteToMove ? Colors.white : Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black54, width: 1.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${whiteToMove ? "White" : "Black"} to move',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                BoardController(
                  state: squaresState.board,
                  playState: state.status == PuzzleStatus.inProgress
                      ? PlayState.ourTurn
                      : PlayState.finished,
                  pieceSet: PieceSet.merida(),
                  theme: BoardTheme.brown,
                  moves: squaresState.moves,
                  onMove: (move) {
                    final uci = move.algebraic();
                    ref
                        .read(puzzleControllerProvider(puzzle).notifier)
                        .tryMove(uci);
                  },
                  markerTheme: MarkerTheme(
                    empty: MarkerTheme.dot,
                    piece: MarkerTheme.corners(),
                  ),
                ),
                IgnorePointer(
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    numberOfParticles: 40,
                    maxBlastForce: 30,
                    minBlastForce: 10,
                    emissionFrequency: 0.04,
                    gravity: 0.25,
                    shouldLoop: false,
                    colors: const [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.purple,
                      Colors.pink,
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _StatusBanner(
            status: state.status,
            moveIndex: state.moveIndex,
            totalMoves: puzzle.solution.length,
            lastWasWrong: state.lastWasWrong,
          ),
          if (state.errors >= 2 && state.status != PuzzleStatus.solved) ...[
            const SizedBox(height: 8),
            Text(
              'Hint: try moving the piece on '
              '${puzzle.solution[state.moveIndex].substring(0, 2)}',
              style: TextStyle(
                color: Colors.amber.shade800,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(puzzleControllerProvider(puzzle).notifier).reset(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              if (solved) ...[
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: widget.isLast
                      ? null
                      : () => context.go('/puzzle/${widget.index + 1}'),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(widget.isLast ? 'All done' : 'Next'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
