import 'package:cloud_firestore/cloud_firestore.dart';

class Puzzle {
  Puzzle({
    required this.id,
    required this.fen,
    required this.solution,
    required this.difficulty,
    required this.themes,
    required this.published,
    required this.createdAt,
  });

  final String id;

  /// Starting position in Forsyth-Edwards Notation.
  final String fen;

  /// Solution moves in UCI long-algebraic form (e.g. `e2e4`).
  /// The side to move at `fen` plays solution[0], opponent plays solution[1], etc.
  final List<String> solution;

  /// 1–5 or a Glicko-style rating, depending on what admin enters.
  final num difficulty;

  /// Tags such as `fork`, `pin`, `mateIn2`.
  final List<String> themes;

  final bool published;
  final DateTime createdAt;

  factory Puzzle.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;
    return Puzzle(
      id: snap.id,
      fen: data['fen'] as String,
      solution: List<String>.from(data['solution'] as List),
      difficulty: data['difficulty'] as num,
      themes: List<String>.from(data['themes'] as List? ?? const []),
      published: data['published'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
