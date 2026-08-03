import 'package:bobo/features/home/data/models/restaurant_model.dart';
import 'package:meta/meta.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<Restaurant> restaurants;
  final List<String> categories;

  HomeLoaded({required this.restaurants, required this.categories});
}

final class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
