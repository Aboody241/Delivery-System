import 'package:bobo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bobo/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final responseData = await _remoteDataSource.login(email, password);
    if (responseData != null && responseData['status'] == 'success') {
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
      await prefs.setString('user_image_url', user['image_url'] ?? '');

      return {
        'uid': user['id'].toString(),
        'email': user['email'],
      };
    } else {
      throw responseData?['message'] ?? 'Login failed';
    }
  }

  @override
  Future<Map<String, dynamic>?> register(String email, String password) async {
    final responseData = await _remoteDataSource.register(email, password);
    if (responseData != null && responseData['status'] == 'success') {
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
      await prefs.setString('user_image_url', user['image_url'] ?? '');

      return {
        'uid': user['id'].toString(),
        'email': user['email'],
      };
    } else {
      throw responseData?['message'] ?? 'Registration failed';
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Silent error
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_uid');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_phone');
      await prefs.remove('user_address');
      await prefs.remove('user_image_url');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  @override
  Future<String?> getCurrentUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  @override
  Future<String?> getCurrentUserImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_image_url');
  }
}
