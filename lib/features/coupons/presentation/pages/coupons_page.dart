import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discount Coupons')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCouponCard(context, 'AMAZON10', '10% OFF on Amazon Egypt', 'Amazon', Colors.orange),
          _buildCouponCard(context, 'NOON20', '20% OFF on Noon Egypt', 'Noon', Colors.yellow[700]!),
          _buildCouponCard(context, 'JUMIA15', '15% OFF on Jumia', 'Jumia', Colors.black),
        ],
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, String code, String description, String store, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: color, radius: 20, child: Text(store[0], style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(description, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
                  child: const Text('Copy'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade().slideY(begin: 0.1, end: 0);
  }
}
