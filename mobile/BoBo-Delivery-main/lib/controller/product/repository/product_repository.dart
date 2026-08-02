import 'package:bobo/features/home/models/products_model.dart';
import 'package:bobo/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class ProductRepository {
  final Dio _dio = DioClient().dio;

  ProductRepository();

  Future<List<Product>> getProducts() async {
    try {
      // 1. Fetch active restaurants
      final restaurantsResponse = await _dio.get('/restaurants');
      int restaurantId = 1; // Default fallback ID

      if (restaurantsResponse.data != null && 
          restaurantsResponse.data['status'] == 'success') {
        final List restaurants = restaurantsResponse.data['data'] ?? [];
        if (restaurants.isNotEmpty) {
          restaurantId = restaurants.first['id'] ?? 1;
        }
      }

      // 2. Fetch products of the selected restaurant
      final response = await _dio.get('/restaurants/$restaurantId/products');
      final responseData = response.data;

      if (responseData['status'] == 'success') {
        final List dataList = responseData['data'] ?? [];
        return dataList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw responseData['message'] ?? 'Failed to load products';
      }
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}
