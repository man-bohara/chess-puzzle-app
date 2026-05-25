import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/progress/progress_store.dart';
import 'core/progress/puzzle_progress_db.dart';
import 'core/sound/sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressStore.init();
  await PuzzleProgressDb.instance.init();
  SoundService.instance.init();
  runApp(const ProviderScope(child: ChessPuzzleApp()));
}
