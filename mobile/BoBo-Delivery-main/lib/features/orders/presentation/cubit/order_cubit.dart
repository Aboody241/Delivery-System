import 'package:bobo/features/orders/presentation/cubit/order_state.dart';
import 'package:bobo/features/orders/data/models/order_model.dart';
import 'package:bobo/features/orders/domain/repositories/order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;

  OrderCubit({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrderInitial());

  Future<void> placeOrder(OrderModel order) async {
    emit(OrderPlaceLoading());
    try {
      await _orderRepository.placeOrder(order);
      emit(OrderPlaceSuccess());
    } catch (e) {
      emit(OrderPlaceError(e.toString()));
    }
  }

  Future<void> fetchUserOrders(String userId) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getUserOrders(userId);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
