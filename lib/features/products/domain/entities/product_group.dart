import 'package:equatable/equatable.dart';
import 'product.dart';

class ProductGroup extends Equatable {
  final String productName;
  final List<Product> variants;

  const ProductGroup({
    required this.productName,
    required this.variants,
  });

  Product get lowestPriceVariant {
    return variants.reduce((a, b) => a.currentPrice < b.currentPrice ? a : b);
  }

  List<Product> get sortedVariants {
    final sorted = List<Product>.from(variants);
    sorted.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
    return sorted;
  }

  @override
  List<Object?> get props => [productName, variants];
}
