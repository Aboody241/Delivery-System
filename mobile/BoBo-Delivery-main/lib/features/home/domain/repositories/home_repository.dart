import 'package:bobo/features/home/data/models/restaurant_model.dart';
import 'package:bobo/features/home/data/models/products_model.dart';
import 'package:bobo/features/home/data/models/category_model.dart';

abstract class HomeRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<List<String>> getCategories();
  Future<List<RestaurantCategory>> getRestaurantCategories(int restaurantId);
  Future<List<Product>> getRestaurantProducts(int restaurantId);
}
