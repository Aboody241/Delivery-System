import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email.trim(),
        'password': password.trim(),
      });
      return response.data;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Connection failed';
      throw errorMsg;
    }
  }

  Future<Map<String, dynamic>?> register(String email, String password) async {
    try {
      final name = email.split('@').first;
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email.trim(),
        'password': password.trim(),
        'password_confirmation': password.trim(),
      });
      return response.data;
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
    }
  }
}
