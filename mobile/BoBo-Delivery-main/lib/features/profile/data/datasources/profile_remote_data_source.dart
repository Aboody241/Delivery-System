import 'package:dio/dio.dart';

class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource(this._dio);

  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final response = await _dio.get('/me');
      final responseData = response.data;
      if (responseData['status'] == 'success') {
        return responseData['data'];
      }
      return null;
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Failed to fetch user profile';
    }
  }

  Future<Map<String, dynamic>?> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _dio.put('/me', data: {
        'name': name,
        'phone': phone,
        'address': address,
      });
      final responseData = response.data;
      if (responseData['status'] == 'success') {
        return responseData['data'];
      } else {
        throw responseData['message'] ?? 'Profile update failed';
      }
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    }
  }
}
