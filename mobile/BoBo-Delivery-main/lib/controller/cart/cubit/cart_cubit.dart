import 'package:bobo/features/cart/models/cart_class.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<List<CartItem>> {
  CartCubit() : super([]);

  void addItem(CartItem item) {
    final existingIndex = state.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state);
      updatedList[existingIndex].quantity += 1;
      emit(updatedList);
    } else {
      emit([...state, item]);
    }
  }

  void addItemWithQuantity(CartItem item, int quantity) {
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

  void decrementItem(String id) {
    final existingIndex = state.indexWhere((i) => i.id == id);
    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state);
      if (updatedList[existingIndex].quantity > 1) {
        updatedList[existingIndex].quantity -= 1;
        emit(updatedList);
      } else {
        updatedList.removeAt(existingIndex);
        emit(updatedList);
      }
    }
  }

  void removeItem(String id) {
    emit(state.where((i) => i.id != id).toList());
  }

  void clearCart() {
    emit([]);
  }
}
