import 'package:bobo/controller/order/cubit/order_state.dart';
import 'package:bobo/controller/order/models/order_model.dart';
import 'package:bobo/controller/order/repository/order_repository.dart';
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
      // Refresh the list implicitly if needed, or rely on fetching it when opening MyOrders
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
