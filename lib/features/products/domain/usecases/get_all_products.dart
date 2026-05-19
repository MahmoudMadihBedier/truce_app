import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<Result<List<Product>>> call({
    int page = 1,
    int limit = 100,
  }) async {
    return await repository.getAllProducts(
      page: page,
      limit: limit,
    );
  }
}
