import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../puzzles/data/puzzle_repository.dart';

class ProgressRepository {
  ProgressRepository(this._db, this._auth);
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _doc(String puzzleId) {
    final uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('progress').doc(puzzleId);
  }

  Future<void> recordAttempt(String puzzleId, {required bool solved}) {
    return _doc(puzzleId).set({
      'solved': solved,
      'attempts': FieldValue.increment(1),
      if (solved) 'solvedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});
