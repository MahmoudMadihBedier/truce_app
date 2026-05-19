import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';
import 'product_remote_datasource.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductModel>> getAllProducts({int page = 1, int limit = 100}) async {
    final response = await _apiClient.get(
      '/api/all-products',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List productsJson = response.data['products'] ?? [];
    return productsJson.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getProducts({
    String? productName,
    String? brandName,
    String? category,
    String? storeName,
    int page = 1,
    int limit = 50,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      'limit': limit,
    };

    if (productName != null) queryParameters['product_name'] = productName;
    if (brandName != null) queryParameters['brand_name'] = brandName;
    if (category != null) queryParameters['category'] = category;
    if (storeName != null) queryParameters['store_name'] = storeName;

    final response = await _apiClient.get(
      '/api/products',
      queryParameters: queryParameters,
    );

    final List productsJson = response.data['products'] ?? [];
    return productsJson.map((json) => ProductModel.fromJson(json)).toList();
  }
}
