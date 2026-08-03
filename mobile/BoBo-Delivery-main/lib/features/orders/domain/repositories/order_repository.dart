import 'package:bobo/features/orders/data/models/order_model.dart';

abstract class OrderRepository {
  Future<void> placeOrder(OrderModel order);
  Future<List<OrderModel>> getUserOrders(String userId);
}
