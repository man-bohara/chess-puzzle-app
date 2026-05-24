import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/puzzle.dart';

final _puzzlesAsset = 'assets/puzzles.json';

Future<List<Puzzle>> _loadBundledPuzzles() async {
  final raw = await rootBundle.loadString(_puzzlesAsset);
  final list = jsonDecode(raw) as List;
  return list
      .cast<Map<String, dynamic>>()
      .map(Puzzle.fromJson)
      .toList(growable: false);
}

final puzzlesProvider = FutureProvider<List<Puzzle>>((_) => _loadBundledPuzzles());

final puzzleByIdProvider = FutureProvider.family<Puzzle?, String>(
  (ref, id) async {
    final list = await ref.watch(puzzlesProvider.future);
    for (final p in list) {
      if (p.id == id) return p;
    }
    return null;
  },
);
