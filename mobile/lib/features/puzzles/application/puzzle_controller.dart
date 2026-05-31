import 'package:bishop/bishop.dart' as bishop;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/progress/puzzle_progress_db.dart';
import '../domain/puzzle.dart';

class PuzzleAttemptState {
  PuzzleAttemptState({
    required this.puzzle,
    required this.game,
    required this.moveIndex,
    required this.status,
    this.errors = 0,
    this.lastWasWrong = false,
  });

  final Puzzle puzzle;
  final bishop.Game game;

  /// How many solution moves the player has correctly played so far.
  final int moveIndex;
  final PuzzleStatus status;

  /// Total wrong attempts in the current run. Resets on [PuzzleController.reset].
  final int errors;

  /// True if the most recent attempt was wrong. Cleared once the player makes
  /// a correct move or resets.
  final bool lastWasWrong;

  bool get isComplete => moveIndex >= puzzle.solution.length;

  PuzzleAttemptState copyWith({
    bishop.Game? game,
    int? moveIndex,
    PuzzleStatus? status,
    int? errors,
    bool? lastWasWrong,
  }) =>
      PuzzleAttemptState(
        puzzle: puzzle,
        game: game ?? this.game,
        moveIndex: moveIndex ?? this.moveIndex,
        status: status ?? this.status,
        errors: errors ?? this.errors,
        lastWasWrong: lastWasWrong ?? this.lastWasWrong,
      );
}

enum PuzzleStatus { inProgress, solved }

class PuzzleController extends StateNotifier<PuzzleAttemptState> {
  PuzzleController(Puzzle puzzle, {bool startSolved = false})
      : super(_buildState(puzzle, startSolved: startSolved));

  static PuzzleAttemptState _buildState(
    Puzzle puzzle, {
    required bool startSolved,
  }) {
    final game = bishop.Game(fen: puzzle.fen);
    if (startSolved) {
      for (final move in puzzle.solution) {
        game.makeMoveString(move);
      }
      return PuzzleAttemptState(
        puzzle: puzzle,
        game: game,
        moveIndex: puzzle.solution.length,
        status: PuzzleStatus.solved,
      );
    }
    return PuzzleAttemptState(
      puzzle: puzzle,
      game: game,
      moveIndex: 0,
      status: PuzzleStatus.inProgress,
    );
  }

  void reset() {
    state = _buildState(state.puzzle, startSolved: false);
  }

  /// Attempt the next user move. Returns true if it matched the expected solution move.
  /// A wrong move increments [errors] but keeps the puzzle in progress so the player can retry.
  bool tryMove(String uciMove) {
    if (state.status != PuzzleStatus.inProgress) return false;
    final expected = state.puzzle.solution[state.moveIndex];
    if (uciMove != expected) {
      state = state.copyWith(
        errors: state.errors + 1,
        lastWasWrong: true,
      );
      return false;
    }
    state.game.makeMoveString(uciMove);
    var nextIndex = state.moveIndex + 1;

    // Play the opponent's reply automatically (it's part of `solution`).
    if (nextIndex < state.puzzle.solution.length) {
      final reply = state.puzzle.solution[nextIndex];
      state.game.makeMoveString(reply);
      nextIndex += 1;
    }

    state = state.copyWith(
      moveIndex: nextIndex,
      status: nextIndex >= state.puzzle.solution.length
          ? PuzzleStatus.solved
          : PuzzleStatus.inProgress,
      lastWasWrong: false,
    );
    return true;
  }
}

final puzzleControllerProvider = StateNotifierProvider.family<
    PuzzleController, PuzzleAttemptState, Puzzle>(
  (ref, puzzle) => PuzzleController(
    puzzle,
    startSolved: PuzzleProgressDb.instance.isSolved(puzzle.id),
  ),
);
