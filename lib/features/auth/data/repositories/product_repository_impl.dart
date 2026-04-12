import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await DioClient.instance.get(ApiConstants.products);
    final List<dynamic> data = response.data['data'];
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }
}