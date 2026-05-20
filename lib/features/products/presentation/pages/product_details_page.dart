import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_group.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final ProductGroup? group;

  const ProductDetailsPage({super.key, required this.product, this.group});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Live prices from 4 platforms', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const Icon(Icons.star_half, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text('(2,341 reviews)', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: [
                            _buildTag('5G'),
                            _buildTag('128GB'),
                            _buildTag('Official warranty'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Price List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: (group?.sortedVariants ?? [product]).map((variant) {
                  final isBest = variant.id == group?.lowestPriceVariant.id;
                  return _buildStoreCard(context, variant, isBest);
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildStoreCard(BuildContext context, Product variant, bool isBest) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isBest ? Border.all(color: primaryColor, width: 2) : Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Stack(
        children: [
          if (isBest)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFC8922A),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(18), bottomLeft: Radius.circular(12)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('BEST PRICE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      radius: 18,
                      child: Text(variant.storeName[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(variant.storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Row(
                          children: [
                            const Icon(Icons.check_box, color: Colors.green, size: 14),
                            const SizedBox(width: 4),
                            Text('Free delivery · Ships in 1-2 days', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Coupon Area
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Coupon available — extra 5% off', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('TRUCE5', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                      const SizedBox(width: 8),
                      const Text('Copy', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${variant.currentPrice.toStringAsFixed(0)} EGP',
                          style: TextStyle(color: primaryColor, fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                        if (variant.previousPrice != null)
                          Text('${variant.previousPrice!.toStringAsFixed(0)} EGP original',
                              style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    const Spacer(),
                    if (variant.previousPrice != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Text('Save ${(variant.previousPrice! - variant.currentPrice).toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                            const Text('LE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _launchURL(variant.url),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Shop on ${variant.storeName} →', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
        debugPrint('Could not launch $url');
    }
  }
}
