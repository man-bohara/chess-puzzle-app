import 'package:shared_preferences/shared_preferences.dart';

/// Persists the index of the last puzzle the user opened, so the app can
/// resume there on the next launch.
class ProgressStore {
  ProgressStore._();
  static const _key = 'current_puzzle_index';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static int get currentIndex => _prefs.getInt(_key) ?? 0;

  static Future<void> setCurrentIndex(int index) =>
      _prefs.setInt(_key, index);
}
