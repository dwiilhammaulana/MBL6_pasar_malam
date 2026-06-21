import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  @override
  Future<CartModel> getCart() async {
    final response = await DioClient.instance.get(ApiConstants.cart);
    final rawData = response.data['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : const <String, dynamic>{};
    return CartModel.fromJson(data);
  }

  @override
  Future<void> addToCart(int productId, int quantity) async {
    await DioClient.instance.post(
      ApiConstants.cart,
      data: {'product_id': productId, 'quantity': quantity},
    );
  }

  @override
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    await DioClient.instance.put(
      '${ApiConstants.cart}/$cartItemId',
      data: {'quantity': quantity},
    );
  }

  @override
  Future<void> removeCartItem(int cartItemId) async {
    await DioClient.instance.delete('${ApiConstants.cart}/$cartItemId');
  }

  @override
  Future<void> clearCart() async {
    await DioClient.instance.delete(ApiConstants.cart);
  }
}
