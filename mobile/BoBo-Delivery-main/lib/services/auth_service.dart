import 'package:bobo/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email.trim(),
        'password': password.trim(),
      });

      final responseData = response.data;
      if (responseData['status'] == 'success') {
        final data = responseData['data'];
        final token = data['access_token'];
        final user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_uid', user['id'].toString());
        await prefs.setString('user_email', user['email'] ?? '');
        await prefs.setString('user_name', user['name'] ?? '');
        await prefs.setString('user_phone', user['phone'] ?? '');
        await prefs.setString('user_address', user['address'] ?? '');

        return {
          'uid': user['id'].toString(),
          'email': user['email'],
        };
      } else {
        throw responseData['message'] ?? 'Login failed';
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Connection failed';
      throw errorMsg;
    }
  }

  Future<Map<String, dynamic>?> registerUser(String email, String password) async {
    try {
      // Extract dummy name from email
      final name = email.split('@').first;

      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email.trim(),
        'password': password.trim(),
        'password_confirmation': password.trim(),
      });

      final responseData = response.data;
      if (responseData['status'] == 'success') {
        final data = responseData['data'];
        final token = data['access_token'];
        final user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_uid', user['id'].toString());
        await prefs.setString('user_email', user['email'] ?? '');
        await prefs.setString('user_name', user['name'] ?? '');
        await prefs.setString('user_phone', user['phone'] ?? '');
        await prefs.setString('user_address', user['address'] ?? '');

        return {
          'uid': user['id'].toString(),
          'email': user['email'],
        };
      } else {
        throw responseData['message'] ?? 'Registration failed';
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Connection failed';
      throw errorMsg;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {
      // Silent error for logout network issues
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_uid');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_phone');
      await prefs.remove('user_address');
    }
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

  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final response = await _dio.get('/me');
      final responseData = response.data;

      if (responseData['status'] == 'success') {
        final user = responseData['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_uid', user['id'].toString());
        await prefs.setString('user_email', user['email'] ?? '');
        await prefs.setString('user_name', user['name'] ?? '');
        await prefs.setString('user_phone', user['phone'] ?? '');
        await prefs.setString('user_address', user['address'] ?? '');
        return user;
      }
      return null;
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Failed to fetch user profile';
    }
  }
}
