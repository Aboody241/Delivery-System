import 'package:dio/dio.dart';

class CartRemoteDataSource {
  final Dio _dio;

  CartRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> fetchCart() async {
    final response = await _dio.get('/cart');
    return response.data;
  }

  Future<Map<String, dynamic>> addItem(String productId, int quantity) async {
    final response = await _dio.post('/cart/items', data: {
      'product_id': productId,
      'quantity': quantity,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateItemQuantity(int cartItemId, int quantity) async {
    final response = await _dio.put('/cart/items/$cartItemId', data: {
      'quantity': quantity,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> removeItem(int cartItemId) async {
    final response = await _dio.delete('/cart/items/$cartItemId');
    return response.data;
  }

  Future<Map<String, dynamic>> clearCart() async {
    final response = await _dio.delete('/cart');
    return response.data;
  }
}
