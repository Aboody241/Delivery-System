import 'package:bobo/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:bobo/features/cart/data/models/cart_class.dart';
import 'package:bobo/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  CartRepositoryImpl(this._remoteDataSource);

  List<CartItem> _parseCartResponse(Map<String, dynamic> responseData) {
    final List itemsList = responseData['data']?['items'] ?? [];
    return itemsList.map((json) {
      return CartItem(
        id: json['product_id']?.toString() ?? '',
        cartItemId: json['id'] ?? 0,
        title: json['product_name'] ?? '',
        price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
        imageUrl: json['product_image_url'] ?? 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        quantity: json['quantity'] ?? 1,
      );
    }).toList();
  }

  @override
  Future<List<CartItem>> fetchCart() async {
    final responseData = await _remoteDataSource.fetchCart();
    if (responseData['status'] == 'success') {
      return _parseCartResponse(responseData);
    }
    throw responseData['message'] ?? 'Failed to fetch cart';
  }

  @override
  Future<List<CartItem>> addItem(CartItem item) async {
    final responseData = await _remoteDataSource.addItem(item.id, 1);
    if (responseData['status'] == 'success') {
      return _parseCartResponse(responseData);
    }
    throw responseData['message'] ?? 'Failed to add item';
  }

  @override
  Future<List<CartItem>> addItemWithQuantity(CartItem item, int quantity) async {
    final responseData = await _remoteDataSource.addItem(item.id, quantity);
    if (responseData['status'] == 'success') {
      return _parseCartResponse(responseData);
    }
    throw responseData['message'] ?? 'Failed to add item';
  }

  @override
  Future<List<CartItem>> decrementItem(String productId, List<CartItem> currentState) async {
    final existingIndex = currentState.indexWhere((i) => i.id == productId);
    if (existingIndex >= 0) {
      final item = currentState[existingIndex];
      final cartItemId = item.cartItemId;

      if (cartItemId == null || cartItemId == 0) {
        return _localDecrement(existingIndex, currentState);
      }

      try {
        if (item.quantity > 1) {
          final responseData = await _remoteDataSource.updateItemQuantity(cartItemId, item.quantity - 1);
          if (responseData['status'] == 'success') {
            return _parseCartResponse(responseData);
          }
        } else {
          final responseData = await _remoteDataSource.removeItem(cartItemId);
          if (responseData['status'] == 'success') {
            return _parseCartResponse(responseData);
          }
        }
      } catch (_) {
        return _localDecrement(existingIndex, currentState);
      }
    }
    return currentState;
  }

  @override
  Future<List<CartItem>> removeItem(String productId, List<CartItem> currentState) async {
    final existingIndex = currentState.indexWhere((i) => i.id == productId);
    if (existingIndex >= 0) {
      final item = currentState[existingIndex];
      final cartItemId = item.cartItemId;

      if (cartItemId == null || cartItemId == 0) {
        return currentState.where((i) => i.id != productId).toList();
      }

      try {
        final responseData = await _remoteDataSource.removeItem(cartItemId);
        if (responseData['status'] == 'success') {
          return _parseCartResponse(responseData);
        }
      } catch (_) {
        return currentState.where((i) => i.id != productId).toList();
      }
    }
    return currentState;
  }

  @override
  Future<void> clearCart() async {
    final responseData = await _remoteDataSource.clearCart();
    if (responseData['status'] != 'success') {
      throw responseData['message'] ?? 'Failed to clear cart';
    }
  }

  List<CartItem> _localDecrement(int index, List<CartItem> list) {
    final updatedList = List<CartItem>.from(list);
    if (updatedList[index].quantity > 1) {
      updatedList[index].quantity -= 1;
    } else {
      updatedList.removeAt(index);
    }
    return updatedList;
  }
}
