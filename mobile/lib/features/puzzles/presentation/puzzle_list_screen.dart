import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/puzzle_repository.dart';

class PuzzleListScreen extends ConsumerWidget {
  const PuzzleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzles = ref.watch(publishedPuzzlesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Puzzles')),
      body: puzzles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final p = list[i];
            return ListTile(
              title: Text('Puzzle ${p.id.substring(0, 6)}'),
              subtitle: Text('Difficulty ${p.difficulty} · ${p.themes.join(", ")}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/puzzles/${p.id}'),
            );
          },
        ),
      ),
    );
  }
}
