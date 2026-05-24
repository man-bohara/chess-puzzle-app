class Puzzle {
  Puzzle({
    required this.id,
    required this.fen,
    required this.solution,
    required this.difficulty,
    required this.themes,
    this.caption,
  });

  final String id;

  /// Starting position in Forsyth-Edwards Notation.
  final String fen;

  /// Solution moves in UCI long-algebraic form (e.g. `e2e4`).
  /// The side to move at `fen` plays solution[0], opponent plays solution[1], etc.
  final List<String> solution;

  /// 1–5 difficulty rating.
  final num difficulty;

  /// Tags such as `fork`, `pin`, `mateIn2`.
  final List<String> themes;

  /// Optional per-puzzle task line shown above the board (e.g. "Find the mate
  /// — white to move"). If null, the solver falls back to a generated
  /// "White/Black to move" derived from [fen].
  final String? caption;

  factory Puzzle.fromJson(Map<String, dynamic> json) => Puzzle(
        id: json['id'] as String,
        fen: json['fen'] as String,
        solution: List<String>.from(json['solution'] as List),
        difficulty: (json['difficulty'] as num?) ?? 3,
        themes: List<String>.from(json['themes'] as List? ?? const []),
        caption: json['caption'] as String?,
      );
}
