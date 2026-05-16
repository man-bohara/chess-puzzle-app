import 'package:chess/chess.dart' as chess;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/puzzle.dart';

/// In-memory state of one puzzle attempt. Created when the solver screen
/// opens; not persisted. Per-user progress (solved/attempts) is written
/// separately via [ProgressRepository] on completion.
class PuzzleAttemptState {
  PuzzleAttemptState({
    required this.puzzle,
    required this.board,
    required this.moveIndex,
    required this.status,
  });

  final Puzzle puzzle;
  final chess.Chess board;

  /// How many solution moves the player has correctly played so far.
  final int moveIndex;
  final PuzzleStatus status;

  bool get isComplete => moveIndex >= puzzle.solution.length;

  PuzzleAttemptState copyWith({
    chess.Chess? board,
    int? moveIndex,
    PuzzleStatus? status,
  }) =>
      PuzzleAttemptState(
        puzzle: puzzle,
        board: board ?? this.board,
        moveIndex: moveIndex ?? this.moveIndex,
        status: status ?? this.status,
      );
}

enum PuzzleStatus { inProgress, solved, failed }

class PuzzleController extends StateNotifier<PuzzleAttemptState> {
  PuzzleController(Puzzle puzzle)
      : super(PuzzleAttemptState(
          puzzle: puzzle,
          board: chess.Chess.fromFEN(puzzle.fen),
          moveIndex: 0,
          status: PuzzleStatus.inProgress,
        ));

  /// Attempt the next user move. Returns true if it matched the expected solution move.
  bool tryMove(String uciMove) {
    if (state.status != PuzzleStatus.inProgress) return false;
    final expected = state.puzzle.solution[state.moveIndex];
    if (uciMove != expected) {
      state = state.copyWith(status: PuzzleStatus.failed);
      return false;
    }
    state.board.move(_uciToMove(uciMove));
    var nextIndex = state.moveIndex + 1;

    // Play the opponent's reply automatically (it's part of `solution`).
    if (nextIndex < state.puzzle.solution.length) {
      final reply = state.puzzle.solution[nextIndex];
      state.board.move(_uciToMove(reply));
      nextIndex += 1;
    }

    state = state.copyWith(
      moveIndex: nextIndex,
      status: nextIndex >= state.puzzle.solution.length
          ? PuzzleStatus.solved
          : PuzzleStatus.inProgress,
    );
    return true;
  }

  Map<String, String> _uciToMove(String uci) => {
        'from': uci.substring(0, 2),
        'to': uci.substring(2, 4),
        if (uci.length > 4) 'promotion': uci.substring(4, 5),
      };
}

final puzzleControllerProvider = StateNotifierProvider.family<
    PuzzleController, PuzzleAttemptState, Puzzle>(
  (ref, puzzle) => PuzzleController(puzzle),
);
