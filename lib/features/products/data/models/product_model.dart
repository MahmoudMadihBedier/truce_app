import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.brand,
    required super.url,
    required super.currentPrice,
    super.previousPrice,
    required super.imageUrl,
    required super.storeName,
    super.discounts,
    required super.availability,
    super.location,
    required super.lastUpdated,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['product_id'] ?? '',
      name: json['product_name'] ?? '',
      category: json['product_category'] ?? '',
      brand: json['brand_name'] ?? 'Unknown',
      url: json['product_url'] ?? '',
      currentPrice: (json['current_price_egp'] as num?)?.toDouble() ?? 0.0,
      previousPrice: (json['previous_price_egp'] as num?)?.toDouble(),
      imageUrl: json['product_image_url'] ?? '',
      storeName: json['store_name'] ?? '',
      discounts: json['discounts_offers'],
      availability: json['availability_status'] ?? 'Unknown',
      location: json['location_city'],
      lastUpdated: json['last_updated_utc'] != null
          ? DateTime.parse(json['last_updated_utc'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': id,
      'product_name': name,
      'product_category': category,
      'brand_name': brand,
      'product_url': url,
      'current_price_egp': currentPrice,
      'previous_price_egp': previousPrice,
      'product_image_url': imageUrl,
      'store_name': storeName,
      'discounts_offers': discounts,
      'availability_status': availability,
      'location_city': location,
      'last_updated_utc': lastUpdated.toIso8601String(),
    };
  }
}
