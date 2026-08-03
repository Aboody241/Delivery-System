import 'package:dio/dio.dart';

class OrderRemoteDataSource {
  final Dio _dio;

  OrderRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> placeOrder(String deliveryAddress, String notes) async {
    try {
      final response = await _dio.post('/orders', data: {
        'delivery_address': deliveryAddress,
        'notes': notes,
      });
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    }
  }

  Future<Map<String, dynamic>> getUserOrders() async {
    try {
      final response = await _dio.get('/orders');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    }
  }
}
