import 'package:bobo/features/cart/data/models/cart_class.dart';

abstract class CartRepository {
  Future<List<CartItem>> fetchCart();
  Future<List<CartItem>> addItem(CartItem item);
  Future<List<CartItem>> addItemWithQuantity(CartItem item, int quantity);
  Future<List<CartItem>> decrementItem(String productId, List<CartItem> currentState);
  Future<List<CartItem>> removeItem(String productId, List<CartItem> currentState);
  Future<void> clearCart();
}
