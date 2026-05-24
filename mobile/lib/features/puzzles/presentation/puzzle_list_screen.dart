import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/puzzle_repository.dart';
import '../domain/puzzle.dart';

enum _Category { easy, medium, hard }

extension on _Category {
  String get label => switch (this) {
        _Category.easy => 'Easy',
        _Category.medium => 'Medium',
        _Category.hard => 'Hard',
      };

  bool matches(num difficulty) => switch (this) {
        _Category.easy => difficulty <= 2,
        _Category.medium => difficulty >= 3 && difficulty <= 4,
        _Category.hard => difficulty >= 5,
      };
}

class PuzzleListScreen extends ConsumerWidget {
  const PuzzleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzles = ref.watch(puzzlesProvider);

    return DefaultTabController(
      length: _Category.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Puzzles'),
          bottom: TabBar(
            tabs: [
              for (final c in _Category.values) Tab(text: c.label),
            ],
          ),
        ),
        body: puzzles.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) => TabBarView(
            children: [
              for (final c in _Category.values)
                _CategoryList(
                  category: c,
                  puzzles: list.where((p) => c.matches(p.difficulty)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.category, required this.puzzles});
  final _Category category;
  final List<Puzzle> puzzles;

  @override
  Widget build(BuildContext context) {
    if (puzzles.isEmpty) {
      return Center(child: Text('No ${category.label.toLowerCase()} puzzles yet'));
    }
    return ListView.builder(
      itemCount: puzzles.length,
      itemBuilder: (context, i) {
        final p = puzzles[i];
        return ListTile(
          title: Text('Puzzle ${i + 1}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/puzzles/${p.id}'),
        );
      },
    );
  }
}
