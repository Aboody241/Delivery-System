import 'package:bobo/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:bobo/features/home/data/models/products_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FavoriteCubit Tests', () {
    late FavoriteCubit favoriteCubit;
    late Product sampleProduct1;
    late Product sampleProduct2;

    setUp(() {
      favoriteCubit = FavoriteCubit();
      
      sampleProduct1 = Product(
        id: '1',
        categoryId: 10,
        name: 'Classic Burger',
        price: 9.99,
        image: 'burger.png',
        rate: 4.8,
        disc: 'Delicious beef burger',
      );

      sampleProduct2 = Product(
        id: '2',
        categoryId: 10,
        name: 'Veggie Pizza',
        price: 12.99,
        image: 'pizza.png',
        rate: 4.5,
        disc: 'Fresh cheese pizza',
      );
    });

    tearDown(() {
      favoriteCubit.close();
    });

    test('Initial state of FavoriteCubit is empty list', () {
      expect(favoriteCubit.state, isEmpty);
    });

    test('Toggling an item adds it to favorites when not already present', () {
      favoriteCubit.toggleFavorite(sampleProduct1);
      
      expect(favoriteCubit.state, contains(sampleProduct1));
      expect(favoriteCubit.state.length, 1);
      expect(favoriteCubit.isfavorite(sampleProduct1.id), isTrue);
    });

    test('Toggling an item removes it from favorites when already present', () {
      // Add first
      favoriteCubit.toggleFavorite(sampleProduct1);
      expect(favoriteCubit.state, contains(sampleProduct1));
      
      // Toggle again to remove
      favoriteCubit.toggleFavorite(sampleProduct1);
      expect(favoriteCubit.state, isNot(contains(sampleProduct1)));
      expect(favoriteCubit.state, isEmpty);
      expect(favoriteCubit.isfavorite(sampleProduct1.id), isFalse);
    });

    test('isfavorite returns correct status for multiple items', () {
      favoriteCubit.toggleFavorite(sampleProduct1);
      
      expect(favoriteCubit.isfavorite(sampleProduct1.id), isTrue);
      expect(favoriteCubit.isfavorite(sampleProduct2.id), isFalse);
    });
  });
}
