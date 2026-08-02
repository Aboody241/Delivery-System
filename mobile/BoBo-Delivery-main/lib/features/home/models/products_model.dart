class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final double rate;
  final String? disc;
  final String? calories;
  final int? deliveryTime;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.rate,
    required this.disc, this.calories, this.deliveryTime, required this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? json['document id']?.toString() ?? '',
      name: json['name'] ?? 'Product',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      image: json['image_url'] ?? json['image'] ?? 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
      rate: double.tryParse(json['rate']?.toString() ?? '4.5') ?? 4.5,
      disc: json['description'] ?? json['disc'] ?? 'No description available.',
      calories: json['calories'] ?? '350 kcal',
      deliveryTime: json['deliveryTime'] ?? 30,
    );
  }
}
