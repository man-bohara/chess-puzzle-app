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

  /// Reactive solved count — bind to it with `ValueListenableBuilder` to keep
  /// progress indicators in sync with new solves.
  final ValueNotifier<int> solvedCountNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    try {
      if (!kIsWeb) {
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
        debugPrint(
          'PuzzleProgressDb: loaded ${_solvedCache.length} solved puzzles '
          'from $path',
        );
      }
    } catch (e, st) {
      debugPrint('PuzzleProgressDb.init failed: $e\n$st');
    }
    solvedCountNotifier.value = _solvedCache.length;
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
    final wasNew = _solvedCache.add(puzzleId);
    if (wasNew) solvedCountNotifier.value = _solvedCache.length;
    final db = _db;
    if (db == null) return;
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.execute(
        'INSERT OR IGNORE INTO puzzle_progress '
        '(puzzle_id, updated_at) VALUES (?, ?)',
        [puzzleId, now],
      );
      await db.execute(
        '''
        UPDATE puzzle_progress SET
          solved     = 1,
          solved_at  = COALESCE(solved_at, ?),
          attempts   = attempts + 1,
          errors     = errors + ?,
          points     = points + ?,
          updated_at = ?
        WHERE puzzle_id = ?
        ''',
        [now, errors, points, now, puzzleId],
      );
      debugPrint(
        'PuzzleProgressDb: marked $puzzleId solved '
        '(total solved = ${_solvedCache.length})',
      );
    } catch (e, st) {
      debugPrint('PuzzleProgressDb.markSolved($puzzleId) failed: $e\n$st');
    }
  }
}
