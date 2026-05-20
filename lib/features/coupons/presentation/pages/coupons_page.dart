import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truce_app/core/theme/app_colors.dart';

class _CouponData {
  final String platform;
  final int expiresInDays;
  final String description;
  final String code;
  final List<String> tags;
  final Color platformColor;

  const _CouponData({
    required this.platform,
    required this.expiresInDays,
    required this.description,
    required this.code,
    required this.tags,
    required this.platformColor,
  });
}

const _allCoupons = <_CouponData>[
  _CouponData(
    platform: 'Amazon Egypt',
    expiresInDays: 2,
    description: '5% off Electronics over 5,000 EGP',
    code: 'TRUCE5',
    tags: ['Phones', 'Laptops'],
    platformColor: Color(0xFFFF9900),
  ),
  _CouponData(
    platform: 'Noon Egypt',
    expiresInDays: 3,
    description: 'FREE delivery on orders over 300 EGP',
    code: 'NOONSHIP',
    tags: ['All items'],
    platformColor: Color(0xFFFEC52E),
  ),
  _CouponData(
    platform: 'Jumia Egypt',
    expiresInDays: 1,
    description: '10% off Fashion — Eid special',
    code: 'EID10',
    tags: ['Fashion', 'Shoes'],
    platformColor: Color(0xFFE74C3C),
  ),
  _CouponData(
    platform: 'Carrefour Egypt',
    expiresInDays: 7,
    description: '200 EGP off Home Appliances',
    code: 'CARR200',
    tags: ['Home'],
    platformColor: Color(0xFF003CB6),
  ),
];

const _filters = ['All', 'Amazon', 'Noon', 'Jumia', 'Carrefour'];

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  int _selectedFilter = 0;

  List<_CouponData> get _filtered {
    if (_selectedFilter == 0) return _allCoupons;
    final keyword = _filters[_selectedFilter].toLowerCase();
    return _allCoupons.where((c) => c.platform.toLowerCase().contains(keyword)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coupons',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Exclusive codes updated daily for Egypt',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: 72,
      ),
      body: Column(
        children: [
          // Platform filter chips
          Container(
            color: AppColors.primary,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (i) {
                    final selected = _selectedFilter == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? AppColors.primary : Colors.grey.shade300,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            _filters[i],
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.grey.shade700,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // Coupon list
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No coupons available'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      return _CouponCard(
                        coupon: _filtered[index],
                        index: index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final _CouponData coupon;
  final int index;

  const _CouponCard({required this.coupon, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: coupon.platformColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform row
            Row(
              children: [
                // Platform avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: coupon.platformColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      coupon.platform[0],
                      style: TextStyle(
                        color: coupon.platformColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    coupon.platform,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                // Expires
                Text(
                  coupon.expiresInDays == 1
                      ? 'Expires in 1 day'
                      : 'Expires in ${coupon.expiresInDays} days',
                  style: TextStyle(
                    color: coupon.expiresInDays <= 1 ? Colors.red : Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              coupon.description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
            ),

            const SizedBox(height: 12),

            // Coupon code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                coupon.code,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 2.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tags + Copy button row
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: coupon.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: coupon.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code "${coupon.code}" copied to clipboard!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 15),
                  label: const Text('Copy Code', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(delay: (index * 80).ms).slideY(begin: 0.1, end: 0);
  }
}
