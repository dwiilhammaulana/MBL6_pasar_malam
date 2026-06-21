import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final productName =
        json['product_name'] as String? ??
        json['name'] as String? ??
        product?['name'] as String? ??
        '';
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final quantity = json['quantity'] as int? ?? 0;
    final apiSubtotal = (json['subtotal'] as num?)?.toDouble() ?? 0.0;

    return OrderItemModel(
      productId:
          json['product_id'] as int? ??
          product?['ID'] as int? ??
          product?['id'] as int? ??
          0,
      productName: productName,
      price: price,
      quantity: quantity,
      subtotal: apiSubtotal > 0 ? apiSubtotal : price * quantity,
    );
  }

  @override
  List<Object?> get props => [productId, productName, price, quantity, subtotal];
}

class OrderModel extends Equatable {
  final int id;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final String notes;
  final String paymentMethod;
  final String paymentStatus;
  final String? vaNumber;
  final String? gopayDeeplink;
  final String? paidAt;
  final List<OrderItemModel> items;
  final String createdAt;

  const OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.notes,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.vaNumber,
    required this.gopayDeeplink,
    required this.paidAt,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(OrderItemModel.fromJson)
        .toList();
    final totalFromItems = items.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    return OrderModel(
      id: json['id'] as int? ?? json['ID'] as int? ?? 0,
      totalAmount:
          (json['total_amount'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          totalFromItems,
      status: json['status'] as String? ?? 'pending',
      shippingAddress: json['shipping_address'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentStatus:
          json['payment_status'] as String? ??
          json['paymentStatus'] as String? ??
          'pending',
      vaNumber:
          json['va_number'] as String? ??
          json['virtual_account'] as String?,
      gopayDeeplink:
          json['gopay_deeplink'] as String? ??
          json['gopay_url'] as String? ??
          json['deeplink'] as String?,
      paidAt: json['paid_at'] as String?,
      items: items,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  bool get isPaid =>
      paymentStatus == 'paid' ||
      paymentStatus == 'settlement' ||
      status == 'processing' ||
      status == 'shipped' ||
      status == 'delivered';

  @override
  List<Object?> get props => [
    id,
    totalAmount,
    status,
    shippingAddress,
    notes,
    paymentMethod,
    paymentStatus,
    vaNumber,
    gopayDeeplink,
    paidAt,
    items,
    createdAt,
  ];
}
