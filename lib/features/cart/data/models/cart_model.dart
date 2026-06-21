import 'package:equatable/equatable.dart';

class CartProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  const CartProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) =>
      CartProductModel(
        id: json['ID'] as int? ?? json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['image_url'] as String? ?? '',
        category: json['category'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, name, price, imageUrl, category];
}

class CartItemModel extends Equatable {
  final int id;
  final int productId;
  final CartProductModel product;
  final int quantity;
  final double subtotal;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = CartProductModel.fromJson(
      json['product'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    );
    final quantity =
        json['quantity'] as int? ?? json['quantit'] as int? ?? 0;
    final apiSubtotal = (json['subtotal'] as num?)?.toDouble() ?? 0.0;

    return CartItemModel(
      id: json['id'] as int? ?? json['ID'] as int? ?? 0,
      productId:
          json['product_id'] as int? ?? product.id,
      product: product,
      quantity: quantity,
      subtotal: apiSubtotal > 0 ? apiSubtotal : product.price * quantity,
    );
  }

  @override
  List<Object?> get props => [id, productId, product, quantity, subtotal];
}

class CartModel extends Equatable {
  final List<CartItemModel> items;
  final double total;
  final int itemCount;

  const CartModel({
    required this.items,
    required this.total,
    required this.itemCount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(CartItemModel.fromJson)
        .toList();
    final total = items.fold<double>(0.0, (sum, item) => sum + item.subtotal);
    final itemCount = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return CartModel(items: items, total: total, itemCount: itemCount);
  }

  static const empty = CartModel(items: [], total: 0, itemCount: 0);

  @override
  List<Object?> get props => [items, total, itemCount];
}
