import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays short UI sound effects bundled in `assets/sounds/`.
///
/// Call [init] once at app startup to preload sources so the first `play*`
/// fires without disk-load latency. Missing files are tolerated — if a clip
/// isn't shipped, the corresponding `play*` becomes a no-op.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _wrong = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _solved = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _tick = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _safeSet(_wrong, 'sounds/wrong.mp3');
    await _safeSet(_solved, 'sounds/solved.mp3');
    await _safeSet(_tick, 'sounds/tick.mp3');
    _ready = true;
  }

  Future<void> playWrong() => _safePlay(_wrong);
  Future<void> playSolved() => _safePlay(_solved);
  Future<void> playTick() => _safePlay(_tick);

  Future<void> _safeSet(AudioPlayer player, String assetPath) async {
    try {
      await player.setSource(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) debugPrint('SoundService: preload $assetPath failed: $e');
    }
  }

  Future<void> _safePlay(AudioPlayer player) async {
    try {
      await player.seek(Duration.zero);
      await player.resume();
    } catch (e) {
      if (kDebugMode) debugPrint('SoundService: play failed: $e');
    }
  }
}
