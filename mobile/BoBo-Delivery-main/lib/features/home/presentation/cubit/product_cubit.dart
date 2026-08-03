import 'package:bobo/features/home/domain/repositories/home_repository.dart';
import 'package:bobo/features/home/presentation/cubit/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<ProductState> {
  final HomeRepository _homeRepository;

  ProductCubit({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(ProductInitial());

  Future<void> loadProducts() async {
    if (state is ProductLoaded) return;
    
    emit(ProductLoading());
    try {
      final restaurants = await _homeRepository.getRestaurants();
      int restaurantId = 1;
      if (restaurants.isNotEmpty) {
        restaurantId = restaurants.first.id;
      }
      final products = await _homeRepository.getRestaurantProducts(restaurantId);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> refreshProducts() async {
    emit(ProductLoading());
    try {
      final restaurants = await _homeRepository.getRestaurants();
      int restaurantId = 1;
      if (restaurants.isNotEmpty) {
        restaurantId = restaurants.first.id;
      }
      final products = await _homeRepository.getRestaurantProducts(restaurantId);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
