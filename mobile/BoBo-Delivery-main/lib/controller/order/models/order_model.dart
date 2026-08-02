class OrderItem {
  final String productId;
  final String name;
  final String price;
  final String quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      quantity: json['quantaty']?.toString() ?? json['quantity']?.toString() ?? '1',
      imageUrl: json['imageUrl'] ?? 'assets/products/o_pizza.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantaty': quantity,
      'imageUrl': imageUrl,
    };
  }
}

class OrderModel {
  final String orderId;
  final String userId;
  final List<OrderItem> items;
  final String total;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String documentId) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItem> parsedItems = itemsList.map((item) => OrderItem.fromJson(item)).toList();

    DateTime parsedDate;
    if (json['craateAt'] is String) {
      parsedDate = DateTime.tryParse(json['craateAt']) ?? DateTime.now();
    } else if (json['createdAt'] is String) {
      parsedDate = DateTime.tryParse(json['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return OrderModel(
      orderId: json['orderId'] ?? documentId,
      userId: json['userId'] ?? '',
      items: parsedItems,
      total: json['total']?.toString() ?? '0',
      status: json['status'] ?? 'pending',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status,
      'craateAt': createdAt.toIso8601String(),
    };
  }
}
