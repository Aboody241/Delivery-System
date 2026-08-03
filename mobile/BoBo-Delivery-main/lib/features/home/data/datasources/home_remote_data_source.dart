import 'package:dio/dio.dart';

class HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSource(this._dio);

  Future<List<dynamic>> getRestaurants() async {
    try {
      final response = await _dio.get('/restaurants');
      final responseData = response.data;
      if (responseData['status'] == 'success') {
        return responseData['data'] ?? [];
      }
      throw responseData['message'] ?? 'Failed to load restaurants';
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    }
  }

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final responseData = response.data;
      if (responseData['status'] == 'success') {
        return responseData['data'] ?? [];
      }
      throw responseData['message'] ?? 'Failed to load categories';
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    }
  }

  Future<List<dynamic>> getRestaurantCategories(int restaurantId) async {
    try {
      final response = await _dio.get('/restaurants/$restaurantId/categories');
      final responseData = response.data;
      if (responseData['status'] == 'success') {
        return responseData['data'] ?? [];
      }
      throw responseData['message'] ?? 'Failed to load restaurant categories';
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    }
  }

  Future<List<dynamic>> getRestaurantProducts(int restaurantId) async {
    try {
      final response = await _dio.get('/restaurants/$restaurantId/products');
      final responseData = response.data;
      if (responseData['status'] == 'success') {
        return responseData['data'] ?? [];
      }
      throw responseData['message'] ?? 'Failed to load restaurant products';
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    }
  }
}
