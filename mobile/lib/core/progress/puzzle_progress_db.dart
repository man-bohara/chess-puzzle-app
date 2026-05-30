import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'progress_store.dart';

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
  String? _dbPath;
  String? _lastError;
  final Set<String> _solvedCache = {};

  String? get dbPath => _dbPath;
  String? get lastError => _lastError;

  /// Reactive solved count — bind to it with `ValueListenableBuilder` to keep
  /// progress indicators in sync with new solves.
  final ValueNotifier<int> solvedCountNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    try {
      if (!kIsWeb) {
        final path = p.join(await getDatabasesPath(), 'progress.db');
        _dbPath = path;
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
      _lastError = 'init: $e';
      debugPrint('PuzzleProgressDb.init failed: $e\n$st');
    }
    solvedCountNotifier.value = _solvedCache.length;
  }

  /// End-to-end diagnostic. Writes a synthetic row, flushes, re-reads via a
  /// fresh `SELECT`, and counts persisted rows. Returns a multi-line report
  /// the About dialog can render.
  Future<String> selfTest() async {
    final buf = StringBuffer();
    buf.writeln('DB path: ${_dbPath ?? "(none)"}');
    buf.writeln('Web mode: $kIsWeb');
    buf.writeln('DB open: ${_db != null}');
    buf.writeln('Cache size: ${_solvedCache.length}');
    buf.writeln('Prefs saved index: ${ProgressStore.currentIndex}');
    buf.writeln('Notifier index: ${ProgressStore.indexNotifier.value}');
    if (_lastError != null) buf.writeln('Last error: $_lastError');
    final db = _db;
    if (db == null) {
      buf.writeln('-- DB not open, cannot probe --');
      return buf.toString();
    }
    try {
      final totalRows = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM puzzle_progress'),
      );
      final solvedRows = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM puzzle_progress WHERE solved = 1',
        ),
      );
      buf.writeln('Rows total: $totalRows');
      buf.writeln('Rows solved=1: $solvedRows');

      const probeId = '__selftest__';
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.execute(
        'INSERT OR REPLACE INTO puzzle_progress '
        '(puzzle_id, solved, solved_at, attempts, errors, points, updated_at) '
        'VALUES (?, 1, ?, 1, 0, 0, ?)',
        [probeId, now, now],
      );
      final readBack = await db.query(
        'puzzle_progress',
        where: 'puzzle_id = ?',
        whereArgs: [probeId],
      );
      buf.writeln('Probe write+read: ${readBack.length == 1 ? "OK" : "FAIL"}');
      await db.delete(
        'puzzle_progress',
        where: 'puzzle_id = ?',
        whereArgs: [probeId],
      );
      buf.writeln('Probe row cleaned up.');
    } catch (e) {
      buf.writeln('SELF-TEST EXCEPTION: $e');
    }
    return buf.toString();
  }

  /// Wipes all persisted progress (DB rows + in-memory cache). For dev/debug.
  Future<void> resetAll() async {
    _solvedCache.clear();
    solvedCountNotifier.value = 0;
    final db = _db;
    if (db == null) return;
    try {
      await db.delete('puzzle_progress');
    } catch (e) {
      debugPrint('PuzzleProgressDb.resetAll failed: $e');
    }
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
      _lastError = 'markSolved($puzzleId): $e';
      debugPrint('PuzzleProgressDb.markSolved($puzzleId) failed: $e\n$st');
    }
  }
}
