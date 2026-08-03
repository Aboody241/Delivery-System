import 'package:bobo/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:bobo/features/orders/data/models/order_model.dart';
import 'package:bobo/features/orders/domain/repositories/order_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> placeOrder(OrderModel order) async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('user_address') ?? 'Default Customer Address';

    final responseData = await _remoteDataSource.placeOrder(
      address,
      'Order placed via Bobo mobile application.',
    );

    if (responseData['status'] != 'success') {
      throw responseData['message'] ?? 'Failed to place order';
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final responseData = await _remoteDataSource.getUserOrders();
    if (responseData['status'] == 'success') {
      final List dataList = responseData['data'] ?? [];
      return dataList.map((json) => OrderModel.fromJson(json, '')).toList();
    } else {
      throw responseData['message'] ?? 'Failed to load orders';
    }
  }
}
