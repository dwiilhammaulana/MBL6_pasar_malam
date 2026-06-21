import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/repositories/cart_repository.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  final CartRepository _repository = CartRepositoryImpl();

  CartStatus _status = CartStatus.initial;
  CartModel? _cart;
  String? _error;
  bool _isAdding = false;
  bool _isUpdating = false;

  CartStatus get status => _status;
  CartModel? get cart => _cart;
  String? get error => _error;
  bool get isAdding => _isAdding;
  bool get isUpdating => _isUpdating;
  int get itemCount => _cart?.itemCount ?? 0;

  String _messageFromDio(DioException error, String fallback) {
    final data = error.response?.data;
    if (error.response?.statusCode == 404) {
      return 'Endpoint cart belum tersedia di backend';
    }
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    if (data is String && data.isNotEmpty) return data;
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }
    return fallback;
  }

  Future<void> fetchCart() async {
    _status = CartStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _cart = await _repository.getCart();
      _status = CartStatus.loaded;
    } on DioException catch (e) {
      _error = _messageFromDio(e, 'Gagal memuat cart');
      _status = CartStatus.error;
    } catch (e) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _status = CartStatus.error;
    }

    notifyListeners();
  }

  Future<bool> addToCart(int productId, int quantity) async {
    _isAdding = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addToCart(productId, quantity);
      await fetchCart();
      return true;
    } on DioException catch (e) {
      _error = _messageFromDio(e, 'Gagal menambah ke cart');
    } catch (e) {
      _error = 'Terjadi kesalahan. Coba lagi.';
    } finally {
      _isAdding = false;
      notifyListeners();
    }

    return false;
  }

  Future<void> updateItem(int cartItemId, int quantity) async {
    _isUpdating = true;
    notifyListeners();

    try {
      await _repository.updateCartItem(cartItemId, quantity);
      await fetchCart();
    } on DioException catch (e) {
      _error = _messageFromDio(e, 'Gagal mengubah cart');
      _status = CartStatus.error;
    } catch (e) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _status = CartStatus.error;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> removeItem(int cartItemId) async {
    _isUpdating = true;
    notifyListeners();

    try {
      await _repository.removeCartItem(cartItemId);
      await fetchCart();
    } on DioException catch (e) {
      _error = _messageFromDio(e, 'Gagal menghapus item');
      _status = CartStatus.error;
    } catch (e) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _status = CartStatus.error;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isUpdating = true;
    notifyListeners();

    try {
      await _repository.clearCart();
      _cart = CartModel.empty;
      _status = CartStatus.loaded;
      _error = null;
    } on DioException catch (e) {
      _error = _messageFromDio(e, 'Gagal mengosongkan cart');
      _status = CartStatus.error;
    } catch (e) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      _status = CartStatus.error;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
