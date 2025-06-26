// shared_preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  // Singleton instance
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  static SharedPreferences? _preferences;

  // Initialize SharedPreferences instance
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Setters
  static Future<void> setString(String key, String value) async {
    await init();
    await _preferences?.setString(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    await init();
    await _preferences?.setInt(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  // Getters
  static String? getString(String key) {
    init();
    return _preferences?.getString(key);
  }

  static int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  static bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  static double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  // Remove
  static Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  // Clear all
  static Future<void> clear() async {
    await _preferences?.clear();
  }
}
