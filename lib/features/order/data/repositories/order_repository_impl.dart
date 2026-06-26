import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  @override
  Future<OrderModel> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    final response = await DioClient.instance.post(
      ApiConstants.checkout,
      data: {
        'shipping_address': shippingAddress,
        'notes': notes ?? '',
        'payment_method': paymentMethod,
      },
    );
    final data = _extractData(response.data);
    return OrderModel.fromJson(data);
  }

  @override
  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 10}) async {
    final response = await DioClient.instance.get(
      ApiConstants.orders,
      queryParameters: {'page': page, 'limit': limit},
    );
    final rawData = response.data['data'];
    final list = rawData is List<dynamic>
        ? rawData
        : rawData is Map<String, dynamic> && rawData['items'] is List<dynamic>
        ? rawData['items'] as List<dynamic>
        : const <dynamic>[];

    return list
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }

  @override
  Future<OrderModel> getOrderDetail(int orderId) async {
    final response = await DioClient.instance.get('${ApiConstants.orders}/$orderId');
    final data = _extractData(response.data);
    return OrderModel.fromJson(data);
  }

  @override
  Future<OrderModel> markPaymentPaid(int orderId) async {
    final response = await DioClient.instance.post(
      '${ApiConstants.orders}/$orderId/mark-paid',
    );
    final data = _extractData(response.data);
    return OrderModel.fromJson(data);
  }

  Map<String, dynamic> _extractData(dynamic responseData) {
    final rawData = responseData is Map<String, dynamic>
        ? responseData['data']
        : null;
    return rawData is Map<String, dynamic>
        ? rawData
        : responseData is Map<String, dynamic>
        ? responseData
        : const <String, dynamic>{};
  }
}
