import 'package:bobo/features/cart/data/models/cart_class.dart';
import 'package:bobo/features/cart/domain/repositories/cart_repository.dart';
import 'package:bobo/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<List<CartItem>> {
  final CartRepository _cartRepository;
  final AuthRepository _authRepository;

  CartCubit(this._cartRepository, this._authRepository) : super([]) {
    fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      final token = await _authRepository.isLoggedIn();
      if (!token) {
        emit([]);
        return;
      }

      final items = await _cartRepository.fetchCart();
      emit(items);
    } catch (_) {
      // Keep current state on network failure
    }
  }

  Future<void> addItem(CartItem item) async {
    try {
      final items = await _cartRepository.addItem(item);
      emit(items);
    } catch (_) {
      // Fallback: update locally
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
      final items = await _cartRepository.addItemWithQuantity(item, quantity);
      emit(items);
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
    try {
      final items = await _cartRepository.decrementItem(productId, state);
      emit(items);
    } catch (_) {
      // Handled in repository fallback
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      final items = await _cartRepository.removeItem(productId, state);
      emit(items);
    } catch (_) {
      // Handled in repository fallback
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartRepository.clearCart();
      emit([]);
    } catch (_) {
      emit([]);
    }
  }
}
