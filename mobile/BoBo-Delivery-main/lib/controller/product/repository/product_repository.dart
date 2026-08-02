import 'package:bobo/features/home/models/products_model.dart';

class ProductRepository {
  ProductRepository();

  Future<List<Product>> getProducts() async {
    // Return a mock list of products for now
    // In the next step, this will fetch from the Laravel API
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Product(
        id: '1',
        name: 'Zinger Burger',
        price: 7.99,
        image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        rate: 4.8,
        disc: 'Crispy chicken breast with fresh lettuce and mayo in a warm bun.',
        calories: '450 kcal',
        deliveryTime: 25,
      ),
      Product(
        id: '2',
        name: 'Pizza Margherita',
        price: 12.99,
        image: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500',
        rate: 4.6,
        disc: 'Tomato sauce, fresh mozzarella cheese and organic basil.',
        calories: '800 kcal',
        deliveryTime: 30,
      ),
    ];
  }
}
