import '../../../../core/error/result.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts({
    String? productName,
    String? brandName,
    String? category,
    String? storeName,
    int page = 1,
    int limit = 50,
  });

  Future<Result<List<Product>>> getAllProducts({
    int page = 1,
    int limit = 100,
  });
}
