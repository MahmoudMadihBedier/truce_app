import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<Result<List<Product>>> call({
    String? productName,
    String? brandName,
    String? category,
    String? storeName,
    int page = 1,
    int limit = 50,
  }) async {
    return await repository.getProducts(
      productName: productName,
      brandName: brandName,
      category: category,
      storeName: storeName,
      page: page,
      limit: limit,
    );
  }
}
