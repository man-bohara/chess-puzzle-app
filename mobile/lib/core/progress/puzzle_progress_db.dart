import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Per-puzzle progress: solved status, attempts, errors, points.
///
/// On Android/iOS this is backed by SQLite. On web (dev only) it falls back
/// to an in-memory set — solved state survives navigation but not refresh.
/// Solved IDs are mirrored into an in-memory cache so [isSolved] is sync,
/// which lets list/grid UIs render badges without awaiting a query.
class PuzzleProgressDb {
  PuzzleProgressDb._();
  static final PuzzleProgressDb instance = PuzzleProgressDb._();

  Database? _db;
  final Set<String> _solvedCache = {};

  Future<void> init() async {
    if (kIsWeb) return;
    final path = p.join(await getDatabasesPath(), 'progress.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE puzzle_progress (
            puzzle_id  TEXT PRIMARY KEY,
            solved     INTEGER NOT NULL DEFAULT 0,
            solved_at  INTEGER,
            attempts   INTEGER NOT NULL DEFAULT 0,
            errors     INTEGER NOT NULL DEFAULT 0,
            points     INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
    final rows = await _db!.query(
      'puzzle_progress',
      columns: ['puzzle_id'],
      where: 'solved = 1',
    );
    _solvedCache
      ..clear()
      ..addAll(rows.map((r) => r['puzzle_id'] as String));
  }

  bool isSolved(String puzzleId) => _solvedCache.contains(puzzleId);

  int get solvedCount => _solvedCache.length;

  double progressFraction(int totalPuzzles) =>
      totalPuzzles == 0 ? 0 : _solvedCache.length / totalPuzzles;

  /// Upserts a solve. Increments attempts/errors/points; sets solved_at on
  /// the first successful solve only (so re-solves don't overwrite the
  /// original timestamp).
  Future<void> markSolved(
    String puzzleId, {
    int errors = 0,
    int points = 0,
  }) async {
    _solvedCache.add(puzzleId);
    final db = _db;
    if (db == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.rawInsert('''
      INSERT INTO puzzle_progress
        (puzzle_id, solved, solved_at, attempts, errors, points, updated_at)
      VALUES (?, 1, ?, 1, ?, ?, ?)
      ON CONFLICT(puzzle_id) DO UPDATE SET
        solved     = 1,
        solved_at  = COALESCE(solved_at, excluded.solved_at),
        attempts   = attempts + 1,
        errors     = errors + excluded.errors,
        points     = points + excluded.points,
        updated_at = excluded.updated_at
    ''', [puzzleId, now, errors, points, now]);
  }
}
