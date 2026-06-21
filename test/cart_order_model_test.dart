import 'package:flutter_test/flutter_test.dart';
import 'package:pasar_malam/features/cart/data/models/cart_model.dart';
import 'package:pasar_malam/features/order/data/models/order_model.dart';

void main() {
  group('CartModel', () {
    test('parses backend ID fields and recalculates totals from items', () {
      final cart = CartModel.fromJson({
        'items': [
          {
            'id': 11,
            'product_id': 3,
            'product': {
              'ID': 3,
              'name': 'Sepatu Lari Pro',
              'price': 450000,
              'image_url': 'https://example.test/shoe.png',
              'category': 'Running',
            },
            'quantit': 2,
          },
          {
            'ID': 12,
            'product': {
              'id': 4,
              'name': 'Helm Safety',
              'price': 125000,
              'category': 'Safety',
            },
            'quantity': 1,
            'subtotal': 100000,
          },
        ],
        'total': 1,
        'item_count': 99,
      });

      expect(cart.items, hasLength(2));
      expect(cart.items.first.product.id, 3);
      expect(cart.items.first.quantity, 2);
      expect(cart.items.first.subtotal, 900000);
      expect(cart.items.last.id, 12);
      expect(cart.items.last.productId, 4);
      expect(cart.items.last.subtotal, 100000);
      expect(cart.total, 1000000);
      expect(cart.itemCount, 3);
    });
  });

  group('OrderModel', () {
    test('parses order items and payment fallback fields', () {
      final order = OrderModel.fromJson({
        'ID': 77,
        'status': 'pending',
        'shipping_address': 'Jl. Pasar Malam No. 1',
        'notes': 'Tolong cepat',
        'payment_method': 'virtual_account',
        'paymentStatus': 'settlement',
        'virtual_account': '880812345678',
        'gopay_url': 'gopay://pay/77',
        'paid_at': '2026-05-31T10:00:00Z',
        'items': [
          {
            'product': {'ID': 9, 'name': 'APAR 3kg'},
            'price': 300000,
            'quantity': 2,
          },
        ],
        'created_at': '2026-05-31T09:00:00Z',
      });

      expect(order.id, 77);
      expect(order.totalAmount, 600000);
      expect(order.paymentStatus, 'settlement');
      expect(order.vaNumber, '880812345678');
      expect(order.gopayDeeplink, 'gopay://pay/77');
      expect(order.isPaid, isTrue);
      expect(order.items.single.productId, 9);
      expect(order.items.single.productName, 'APAR 3kg');
      expect(order.items.single.subtotal, 600000);
    });

    test('prefers API total fields when they are present', () {
      final order = OrderModel.fromJson({
        'id': 88,
        'total': 750000,
        'items': [
          {'product_id': 1, 'price': 100000, 'quantity': 2},
        ],
      });

      expect(order.totalAmount, 750000);
      expect(order.status, 'pending');
      expect(order.paymentStatus, 'pending');
    });
  });
}
