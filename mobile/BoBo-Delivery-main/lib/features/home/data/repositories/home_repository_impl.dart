import 'package:bobo/features/home/data/datasources/home_remote_data_source.dart';
import 'package:bobo/features/home/data/models/category_model.dart';
import 'package:bobo/features/home/data/models/products_model.dart';
import 'package:bobo/features/home/data/models/restaurant_model.dart';
import 'package:bobo/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Restaurant>> getRestaurants() async {
    final data = await _remoteDataSource.getRestaurants();
    return data.map((json) => Restaurant.fromJson(json)).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final data = await _remoteDataSource.getCategories();
    return data
        .map((json) => json['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  Future<List<RestaurantCategory>> getRestaurantCategories(int restaurantId) async {
    final data = await _remoteDataSource.getRestaurantCategories(restaurantId);
    return data.map((json) => RestaurantCategory.fromJson(json)).toList();
  }

  @override
  Future<List<Product>> getRestaurantProducts(int restaurantId) async {
    final data = await _remoteDataSource.getRestaurantProducts(restaurantId);
    return data.map((json) => Product.fromJson(json)).toList();
  }
}
