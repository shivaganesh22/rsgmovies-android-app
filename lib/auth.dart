
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUsername = 'email';
  static const String _keyPassword = 'password';

  // Store login details
  static Future<void> storeLoginDetails(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyUsername, username);
    prefs.setString(_keyPassword, password);
  }

  // Retrieve login details
  static Future<Map<String, String>> getLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUsername) ?? '';
    final password = prefs.getString(_keyPassword) ?? '';
    return {'email': username, 'password': password};
  }
  static Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUsername);
  }

  // Clear login details
  static Future<void> clearLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_keyUsername);
    prefs.remove(_keyPassword);
  }
}
