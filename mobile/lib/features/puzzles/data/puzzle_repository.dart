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

final puzzleByIndexProvider = FutureProvider.family<Puzzle?, int>(
  (ref, index) async {
    final list = await ref.watch(puzzlesProvider.future);
    if (index < 0 || index >= list.length) return null;
    return list[index];
  },
);

final puzzleCountProvider = FutureProvider<int>(
  (ref) async => (await ref.watch(puzzlesProvider.future)).length,
);
