import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyLastOpened = 'last_opened_at';

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  static Future<String?> getLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastOpened);
  }

  static Future<void> updateLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastOpened, DateTime.now().toIso8601String());
  }
}