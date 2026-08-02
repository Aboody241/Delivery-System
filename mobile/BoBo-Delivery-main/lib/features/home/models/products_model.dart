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
      name: json['name'],
      price: json['price'] * 1.0,
      image: json['image'],
      rate: json['rate'] * 1.0,
      disc: json['disc'] ,
      calories: json['calories'],
      deliveryTime: json['deliveryTime'], 
      id: json['document id'] ?? json['id'] ?? '',
    );
  }
}
