import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? productName,
    String? brandName,
    String? category,
    String? storeName,
    int page = 1,
    int limit = 50,
  });

  Future<List<ProductModel>> getAllProducts({
    int page = 1,
    int limit = 100,
  });
}
