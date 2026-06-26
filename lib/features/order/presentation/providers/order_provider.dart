import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';

enum OrderStatus { initial, loading, success, error }

enum PaymentCheckStatus { idle, checking, paid, pending, error }

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepositoryImpl();

  OrderStatus _checkoutStatus = OrderStatus.initial;
  OrderStatus _ordersStatus = OrderStatus.initial;
  PaymentCheckStatus _paymentCheckStatus = PaymentCheckStatus.idle;
  OrderModel? _lastOrder;
  List<OrderModel> _orders = [];
  String? _error;
  Timer? _paymentPollingTimer;

  OrderStatus get checkoutStatus => _checkoutStatus;
  OrderStatus get ordersStatus => _ordersStatus;
  PaymentCheckStatus get paymentCheckStatus => _paymentCheckStatus;
  OrderModel? get lastOrder => _lastOrder;
  List<OrderModel> get orders => _orders;
  String? get error => _error;
  bool get isCheckingOut => _checkoutStatus == OrderStatus.loading;

  Future<bool> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    _checkoutStatus = OrderStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _lastOrder = await _repository.checkout(
        shippingAddress: shippingAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );
      _checkoutStatus = OrderStatus.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] as String? ?? 'Checkout gagal';
      _checkoutStatus = OrderStatus.error;
    } catch (e) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _checkoutStatus = OrderStatus.error;
    }

    notifyListeners();
    return false;
  }

  Future<void> fetchOrders({int page = 1, int limit = 10}) async {
    _ordersStatus = OrderStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.getMyOrders(page: page, limit: limit);
      _ordersStatus = OrderStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data['message'] as String? ?? 'Gagal memuat pesanan';
      _ordersStatus = OrderStatus.error;
    } catch (e) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _ordersStatus = OrderStatus.error;
    }

    notifyListeners();
  }

  Future<OrderModel?> fetchOrderDetail(int orderId) async {
    try {
      final order = await _repository.getOrderDetail(orderId);
      _lastOrder = order;
      notifyListeners();
      return order;
    } catch (e) {
      return null;
    }
  }

  Future<void> checkPaymentStatus(int orderId) async {
    _paymentCheckStatus = PaymentCheckStatus.checking;
    notifyListeners();

    try {
      final order = await _repository.getOrderDetail(orderId);
      _lastOrder = order;
      _paymentCheckStatus = order.isPaid
          ? PaymentCheckStatus.paid
          : PaymentCheckStatus.pending;
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] as String? ?? 'Gagal mengecek pembayaran';
      _paymentCheckStatus = PaymentCheckStatus.error;
    } catch (e) {
      _error = 'Gagal mengecek pembayaran.';
      _paymentCheckStatus = PaymentCheckStatus.error;
    }

    notifyListeners();
  }

  Future<OrderModel?> markPaymentPaid(int orderId) async {
    _paymentCheckStatus = PaymentCheckStatus.checking;
    _error = null;
    notifyListeners();

    try {
      final order = await _repository.markPaymentPaid(orderId);
      _lastOrder = order;
      _paymentCheckStatus = PaymentCheckStatus.paid;
      notifyListeners();
      return order;
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] as String? ?? 'Gagal mengonfirmasi pembayaran';
      _paymentCheckStatus = PaymentCheckStatus.error;
    } catch (e) {
      _error = 'Gagal mengonfirmasi pembayaran.';
      _paymentCheckStatus = PaymentCheckStatus.error;
    }

    notifyListeners();
    return null;
  }

  void startPaymentPolling(int orderId) {
    stopPaymentPolling();
    _paymentCheckStatus = PaymentCheckStatus.idle;
    _paymentPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      checkPaymentStatus(orderId);
    });
  }

  void stopPaymentPolling() {
    _paymentPollingTimer?.cancel();
    _paymentPollingTimer = null;
  }

  @override
  void dispose() {
    stopPaymentPolling();
    super.dispose();
  }
}
