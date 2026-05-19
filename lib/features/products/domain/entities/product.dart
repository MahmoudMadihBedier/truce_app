import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String url;
  final double currentPrice;
  final double? previousPrice;
  final String imageUrl;
  final String storeName;
  final String? discounts;
  final String availability;
  final String? location;
  final DateTime lastUpdated;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.url,
    required this.currentPrice,
    this.previousPrice,
    required this.imageUrl,
    required this.storeName,
    this.discounts,
    required this.availability,
    this.location,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        brand,
        url,
        currentPrice,
        previousPrice,
        imageUrl,
        storeName,
        discounts,
        availability,
        location,
        lastUpdated,
      ];
}
