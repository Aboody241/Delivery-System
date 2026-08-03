class CartItem {
  final String id; // product_id as string
  final int? cartItemId; // cart_items table row id
  final String title;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    this.cartItemId,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}
