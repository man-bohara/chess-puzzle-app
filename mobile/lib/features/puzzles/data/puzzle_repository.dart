import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/puzzle.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

class PuzzleRepository {
  PuzzleRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _puzzles =>
      _db.collection('puzzles');

  /// Live stream of published puzzles, newest first.
  Stream<List<Puzzle>> watchPublished() {
    return _puzzles
        .where('published', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Puzzle.fromSnapshot).toList());
  }

  Future<Puzzle?> fetch(String id) async {
    final doc = await _puzzles.doc(id).get();
    return doc.exists ? Puzzle.fromSnapshot(doc) : null;
  }
}

final puzzleRepositoryProvider = Provider<PuzzleRepository>(
  (ref) => PuzzleRepository(ref.watch(firestoreProvider)),
);

final publishedPuzzlesProvider = StreamProvider<List<Puzzle>>(
  (ref) => ref.watch(puzzleRepositoryProvider).watchPublished(),
);

final puzzleByIdProvider = FutureProvider.family<Puzzle?, String>(
  (ref, id) => ref.watch(puzzleRepositoryProvider).fetch(id),
);
