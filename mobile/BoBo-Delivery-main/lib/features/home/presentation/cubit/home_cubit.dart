import 'package:bobo/features/home/domain/repositories/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;

  HomeCubit(this._homeRepository) : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());
    try {
      final restaurants = await _homeRepository.getRestaurants();
      final categories = await _homeRepository.getCategories();
      emit(HomeLoaded(
        restaurants: restaurants,
        categories: ['All', ...categories],
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> refreshHomeData() async {
    try {
      final restaurants = await _homeRepository.getRestaurants();
      final categories = await _homeRepository.getCategories();
      emit(HomeLoaded(
        restaurants: restaurants,
        categories: ['All', ...categories],
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
