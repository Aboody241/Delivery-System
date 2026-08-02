import 'package:bobo/features/cart/models/cart_class.dart';
import 'package:bobo/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartCubit extends Cubit<List<CartItem>> {
  final Dio _dio = DioClient().dio;

  CartCubit() : super([]) {
    fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        emit([]);
        return;
      }

      final response = await _dio.get('/cart');
      final responseData = response.data;
      if (responseData['status'] == 'success') {
        _emitCartFromResponse(responseData);
      }
    } catch (_) {
      // Keep current state on network failure
    }
  }

  Future<void> addItem(CartItem item) async {
    try {
      final response = await _dio.post('/cart/items', data: {
        'product_id': item.id,
        'quantity': 1,
      });

      final responseData = response.data;
      if (responseData['status'] == 'success') {
        _emitCartFromResponse(responseData);
      }
    } catch (_) {
      // Fallback: update locally if request fails temporarily
      final existingIndex = state.indexWhere((i) => i.id == item.id);
      if (existingIndex >= 0) {
        final updatedList = List<CartItem>.from(state);
        updatedList[existingIndex].quantity += 1;
        emit(updatedList);
      } else {
        emit([...state, item]);
      }
    }
  }

  Future<void> addItemWithQuantity(CartItem item, int quantity) async {
    try {
      final response = await _dio.post('/cart/items', data: {
        'product_id': item.id,
        'quantity': quantity,
      });

      final responseData = response.data;
      if (responseData['status'] == 'success') {
        _emitCartFromResponse(responseData);
      }
    } catch (_) {
      final existingIndex = state.indexWhere((i) => i.id == item.id);
      if (existingIndex >= 0) {
        final updatedList = List<CartItem>.from(state);
        updatedList[existingIndex].quantity += quantity;
        emit(updatedList);
      } else {
        item.quantity = quantity;
        emit([...state, item]);
      }
    }
  }

  Future<void> decrementItem(String productId) async {
    final existingIndex = state.indexWhere((i) => i.id == productId);
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      final cartItemId = item.cartItemId;

      if (cartItemId == null || cartItemId == 0) {
        // Fallback local decrement
        _localDecrement(existingIndex);
        return;
      }

      try {
        if (item.quantity > 1) {
          final response = await _dio.put('/cart/items/$cartItemId', data: {
            'quantity': item.quantity - 1,
          });
          if (response.data['status'] == 'success') {
            _emitCartFromResponse(response.data);
          }
        } else {
          final response = await _dio.delete('/cart/items/$cartItemId');
          if (response.data['status'] == 'success') {
            _emitCartFromResponse(response.data);
          }
        }
      } catch (_) {
        _localDecrement(existingIndex);
      }
    }
  }

  Future<void> removeItem(String productId) async {
    final existingIndex = state.indexWhere((i) => i.id == productId);
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      final cartItemId = item.cartItemId;

      if (cartItemId == null || cartItemId == 0) {
        emit(state.where((i) => i.id != productId).toList());
        return;
      }

      try {
        final response = await _dio.delete('/cart/items/$cartItemId');
        if (response.data['status'] == 'success') {
          _emitCartFromResponse(response.data);
        }
      } catch (_) {
        emit(state.where((i) => i.id != productId).toList());
      }
    }
  }

  Future<void> clearCart() async {
    try {
      final response = await _dio.delete('/cart');
      if (response.data['status'] == 'success') {
        emit([]);
      }
    } catch (_) {
      emit([]);
    }
  }

  void _localDecrement(int index) {
    final updatedList = List<CartItem>.from(state);
    if (updatedList[index].quantity > 1) {
      updatedList[index].quantity -= 1;
      emit(updatedList);
    } else {
      updatedList.removeAt(index);
      emit(updatedList);
    }
  }

  void _emitCartFromResponse(Map<String, dynamic> responseData) {
    final List itemsList = responseData['data']['items'] ?? [];
    final cartItems = itemsList.map((json) {
      return CartItem(
        id: json['product_id']?.toString() ?? '',
        cartItemId: json['id'] ?? 0,
        title: json['product_name'] ?? '',
        price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
        imageUrl: json['product_image_url'] ?? 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        quantity: json['quantity'] ?? 1,
      );
    }).toList();
    emit(cartItems);
  }
}
