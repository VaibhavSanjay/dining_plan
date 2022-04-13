import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static late final SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setStar(String name) async {
    await _prefs.setBool(name, true);
  }

  static Future<bool> checkStar(String name) async {
    return _prefs.getBool(name) != null;
  }

  static Future<void> removeStar(String name) async {
    await _prefs.remove(name);
  }
}