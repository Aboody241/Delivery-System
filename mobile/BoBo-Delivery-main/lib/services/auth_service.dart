import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // We can write mock auth login/register logic for now
  // Later we'll hook it up to Dio for API calls

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw "Email and password cannot be empty";
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'mock_token_12345');
    await prefs.setString('user_email', email);
    await prefs.setString('user_uid', 'mock_uid_12345');

    return {
      'uid': 'mock_uid_12345',
      'email': email,
    };
  }

  Future<Map<String, dynamic>?> registerUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'mock_token_12345');
    await prefs.setString('user_email', email);
    await prefs.setString('user_uid', 'mock_uid_12345');

    return {
      'uid': 'mock_uid_12345',
      'email': email,
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
    await prefs.remove('user_uid');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  Future<String?> getCurrentUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }
}
