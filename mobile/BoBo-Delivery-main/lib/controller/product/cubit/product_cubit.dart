import 'package:bobo/controller/product/cubit/product_state.dart';
import 'package:bobo/controller/product/repository/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _productRepository;

  ProductCubit({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitial());

  Future<void> loadProducts() async {
    // Only load if not already loaded or loading to prevent redundant reads
    if (state is ProductLoaded) return;
    
    emit(ProductLoading());
    try {
      final products = await _productRepository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> refreshProducts() async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
