import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
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

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ServerFailure('Invalid products response');
    }

    final rawProducts = data['products'];
    if (rawProducts is! List) {
      throw const ServerFailure('Invalid products list');
    }

    final models = <ProductModel>[];
    for (final item in rawProducts) {
      if (item is Map<String, dynamic>) {
        try {
          models.add(ProductModel.fromJson(item));
        } catch (_) {
          // Skip invalid items.
        }
      }
    }
    return models;
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
    if (productName != null && productName.trim().isNotEmpty && productName.trim().length < 2) {
      throw const ValidationFailure('Search query must be at least 2 characters.');
    }

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

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ServerFailure('Invalid products response');
    }

    final rawProducts = data['products'];
    if (rawProducts is! List) {
      throw const ServerFailure('Invalid products list');
    }

    final models = <ProductModel>[];
    for (final item in rawProducts) {
      if (item is Map<String, dynamic>) {
        try {
          models.add(ProductModel.fromJson(item));
        } catch (_) {
          // Skip invalid items.
        }
      }
    }
    return models;
  }
}
