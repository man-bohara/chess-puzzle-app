import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the index of the last puzzle the user opened, so the app can
/// resume there on the next launch.
class ProgressStore {
  ProgressStore._();
  static const _key = 'current_puzzle_index';
  static SharedPreferences? _prefs;

  /// Reactive view of the saved index — bind with `ValueListenableBuilder`
  /// for debug indicators showing what's in storage.
  static final ValueNotifier<int> indexNotifier = ValueNotifier<int>(0);

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      indexNotifier.value = _prefs!.getInt(_key) ?? 0;
      debugPrint(
        'ProgressStore: loaded current_puzzle_index=${indexNotifier.value}',
      );
    } catch (e, st) {
      debugPrint('ProgressStore.init failed: $e\n$st');
    }
  }

  static int get currentIndex => _prefs?.getInt(_key) ?? 0;

  static Future<void> setCurrentIndex(int index) async {
    indexNotifier.value = index;
    final prefs = _prefs;
    if (prefs == null) {
      debugPrint(
        'ProgressStore.setCurrentIndex($index) skipped — _prefs is null',
      );
      return;
    }
    try {
      final ok = await prefs.setInt(_key, index);
      debugPrint('ProgressStore: saved current_puzzle_index=$index (ok=$ok)');
    } catch (e, st) {
      debugPrint('ProgressStore.setCurrentIndex($index) failed: $e\n$st');
    }
  }
}
