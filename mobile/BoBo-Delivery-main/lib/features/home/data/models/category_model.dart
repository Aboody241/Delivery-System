class RestaurantCategory {
  final int id;
  final String name;

  RestaurantCategory({required this.id, required this.name});

  factory RestaurantCategory.fromJson(Map<String, dynamic> json) {
    return RestaurantCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
