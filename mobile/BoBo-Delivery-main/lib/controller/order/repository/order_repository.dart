import 'package:bobo/controller/order/models/order_model.dart';
import 'package:bobo/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepository {
  final Dio _dio = DioClient().dio;

  OrderRepository();

  Future<void> placeOrder(OrderModel order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final address = prefs.getString('user_address') ?? 'Default Customer Address';

      final response = await _dio.post('/orders', data: {
        'delivery_address': address,
        'notes': 'Order placed via Bobo mobile application.',
      });

      final responseData = response.data;
      if (responseData['status'] != 'success') {
        throw responseData['message'] ?? 'Failed to place order';
      }
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final response = await _dio.get('/orders');
      final responseData = response.data;

      if (responseData['status'] == 'success') {
        final List dataList = responseData['data'] ?? [];
        return dataList.map((json) => OrderModel.fromJson(json, '')).toList();
      } else {
        throw responseData['message'] ?? 'Failed to load orders';
      }
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.message ?? 'Connection error';
    }
  }
}
