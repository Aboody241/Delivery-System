import 'package:bloc/bloc.dart';
import 'package:bobo/features/home/models/products_model.dart';
import 'package:meta/meta.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<List<Product>> {
  FavoriteCubit() : super([]);

  void toggleFavorite(Product product) {
    final current = List<Product>.from(state);

    if (current.any((item) => item.id == product.id)) {
      current.removeWhere((item) => item.id == product.id);
    } else {
      current.add(product);
    }

    emit(current);
  }

  bool isfavorite(String productId) {
    return state.any((item) => item.id == productId);
  }
}
