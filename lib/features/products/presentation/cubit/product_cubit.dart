import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_group.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/get_products.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetAllProducts _getAllProducts;
  final GetProducts _getProducts;

  ProductCubit({
    required GetAllProducts getAllProducts,
    required GetProducts getProducts,
  })  : _getAllProducts = getAllProducts,
        _getProducts = getProducts,
        super(ProductInitial());

  Future<void> fetchAllProducts() async {
    emit(ProductLoading());
    final result = await _getAllProducts();
    if (result.isSuccess) {
      final groups = _groupProducts(result.data!);
      emit(ProductLoaded(result.data!, groups));
    } else {
      emit(ProductError(result.failure!.message));
    }
  }

  Future<void> searchProducts(String query) async {
    emit(ProductLoading());
    final result = await _getProducts(productName: query);
    if (result.isSuccess) {
      final groups = _groupProducts(result.data!);
      emit(ProductLoaded(result.data!, groups));
    } else {
      emit(ProductError(result.failure!.message));
    }
  }

  List<ProductGroup> _groupProducts(List<Product> products) {
    final Map<String, List<Product>> groupsMap = {};
    for (var product in products) {
      final key = product.name.toLowerCase().trim();
      if (!groupsMap.containsKey(key)) {
        groupsMap[key] = [];
      }
      groupsMap[key]!.add(product);
    }

    return groupsMap.entries.map((e) {
      return ProductGroup(productName: e.value.first.name, variants: e.value);
    }).toList();
  }
}
