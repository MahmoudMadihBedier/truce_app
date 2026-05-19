import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<Product>>> getAllProducts({int page = 1, int limit = 100}) async {
    try {
      final remoteProducts = await remoteDataSource.getAllProducts(
        page: page,
        limit: limit,
      );
      return Result.success(remoteProducts);
    } on Failure catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getProducts({
    String? productName,
    String? brandName,
    String? category,
    String? storeName,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final remoteProducts = await remoteDataSource.getProducts(
        productName: productName,
        brandName: brandName,
        category: category,
        storeName: storeName,
        page: page,
        limit: limit,
      );
      return Result.success(remoteProducts);
    } on Failure catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
