import 'package:bobo/controller/order/models/order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;

  OrderLoaded(this.orders);
}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);
}

class OrderPlaceLoading extends OrderState {}

class OrderPlaceSuccess extends OrderState {}

class OrderPlaceError extends OrderState {
  final String message;

  OrderPlaceError(this.message);
}
