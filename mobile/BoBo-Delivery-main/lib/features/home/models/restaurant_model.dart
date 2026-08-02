class Restaurant {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String imageUrl;
  final bool isActive;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.imageUrl,
    required this.isActive,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Restaurant',
      description: json['description'] ?? 'Delicious meals delivered to your door.',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      imageUrl: json['image_url'] ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500',
      isActive: json['is_active'] ?? true,
    );
  }
}
