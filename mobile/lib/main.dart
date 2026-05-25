import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/sound/sound_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SoundService.instance.init();
  runApp(const ProviderScope(child: ChessPuzzleApp()));
}
