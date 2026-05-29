import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<Result<List<Product>>> call({
    String? query,
    String? category,
    String? storeName,
    int page = 1,
    int limit = 50,
  }) async {
    final hasFilters = (query != null && query.trim().isNotEmpty) || category != null || storeName != null;
    if (hasFilters) {
      return repository.getProducts(
        productName: query,
        category: category,
        storeName: storeName,
        page: page,
        limit: limit,
      );
    }

    return repository.getAllProducts(page: page, limit: limit);
  }
}

