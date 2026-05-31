import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the index of the last puzzle the user opened, so the app can
/// resume there on the next launch.
class ProgressStore {
  ProgressStore._();
  static const _key = 'current_puzzle_index';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e, st) {
      debugPrint('ProgressStore.init failed: $e\n$st');
    }
  }

  static int get currentIndex => _prefs?.getInt(_key) ?? 0;

  static Future<void> setCurrentIndex(int index) async {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      await prefs.setInt(_key, index);
    } catch (e, st) {
      debugPrint('ProgressStore.setCurrentIndex($index) failed: $e\n$st');
    }
  }
}
