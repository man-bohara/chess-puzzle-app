import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays short UI sound effects bundled in `assets/sounds/`.
///
/// Missing files are tolerated — if `wrong.mp3` or `solved.mp3` isn't shipped,
/// `play*` becomes a no-op so the app still works.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _wrong = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _solved = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<void> playWrong() => _safePlay(_wrong, 'sounds/wrong.mp3');
  Future<void> playSolved() => _safePlay(_solved, 'sounds/solved.mp3');

  Future<void> _safePlay(AudioPlayer player, String assetPath) async {
    try {
      await player.stop();
      await player.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) debugPrint('SoundService: $assetPath failed: $e');
    }
  }
}
