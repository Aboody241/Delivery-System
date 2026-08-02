import 'package:bobo/controller/order/models/order_model.dart';

class OrderRepository {
  OrderRepository();

  Future<void> placeOrder(OrderModel order) async {
    // Mock order placement
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    // Return a mock list of user orders
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      OrderModel(
        orderId: 'order_1',
        userId: userId,
        total: '20.98',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        items: [
          OrderItem(
            productId: '1',
            name: 'Zinger Burger',
            price: '7.99',
            quantity: '2',
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
          ),
        ],
      ),
    ];
  }
}
