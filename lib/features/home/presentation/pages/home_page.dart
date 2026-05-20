import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truce_app/features/products/presentation/cubit/product_cubit.dart';
import 'package:truce_app/features/products/presentation/widgets/product_card.dart';
import 'package:truce_app/features/products/presentation/pages/product_details_page.dart';
import 'package:truce_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truce_app/features/auth/presentation/pages/login_page.dart';
import 'package:truce_app/features/market/presentation/cubit/market_cubit.dart';
import 'package:truce_app/features/market/domain/entities/market_rate.dart';
import 'package:truce_app/core/widgets/shimmer_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchAllProducts();
    context.read<MarketCubit>().fetchRates();

    // Show guest login prompt after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState.user.isGuest) {
        _showGuestLoginPrompt();
      }
    });
  }

  void _showGuestLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up for More Features'),
        content: const Text('Unlock price alerts, saved products, and more by creating an account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logOut();
            },
            child: const Text('Login / Sign Up'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final user = context.watch<AuthCubit>().state.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user, primaryColor),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMarketOverview(),
                _buildCategories(),
                _buildPromoBanner(),
                _buildSectionHeader('Featured Deals', () {}),
              ],
            ),
          ),
          _buildFeaturedGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, dynamic user, Color primaryColor) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(color: primaryColor),
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withValues(alpha: 0.1)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 60),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                      ),
                      Text(
                        user?.displayName ?? user?.email?.split('@')[0] ?? 'Guest User',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketOverview() {
    return BlocBuilder<MarketCubit, List<MarketRate>>(
      builder: (context, rates) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Market Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: rates.isEmpty
                    ? [
                        Expanded(child: ShimmerLoader(width: double.infinity, height: 80)),
                        const SizedBox(width: 12),
                        Expanded(child: ShimmerLoader(width: double.infinity, height: 80)),
                      ]
                    : rates.map((rate) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: rate == rates.last ? 0 : 12),
                            child: _buildMarketCard(rate.label, '${rate.price.toStringAsFixed(0)} EGP', '${rate.changePercentage}%',
                                rate.isUp ? Colors.amber.shade700 : Colors.green.shade700, rate.isUp),
                          ),
                        );
                      }).toList(),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
        );
      },
    );
  }

  Widget _buildMarketCard(String label, String price, String change, Color color, bool isUp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 12),
              const SizedBox(width: 4),
              Text(change, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.smartphone, 'label': 'Phones'},
      {'icon': Icons.laptop, 'label': 'Laptops'},
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.checkroom, 'label': 'Fashion'},
      {'icon': Icons.restaurant, 'label': 'Grocery'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                  ]),
                  child: Icon(categories[index]['icon'] as IconData, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 8),
                Text(categories[index]['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=2070&auto=format&fit=crop'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Super Friday Deals', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Up to 70% off on global brands', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Explore Now'),
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 300.ms);
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onSeeAll, child: const Text('See All')),
        ],
      ),
    );
  }

  Widget _buildFeaturedGrid() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildListDelegate(List.generate(4, (_) => ShimmerLoader.productCard())),
            ),
          );
        }

        if (state is ProductLoaded) {
          final products = state.products.take(6).toList();
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  final group = state.groups.firstWhere(
                    (g) => g.productName == product.name,
                    orElse: () => throw Exception('Group not found'),
                  );
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(
                            product: product,
                            group: group,
                          ),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                },
                childCount: products.length,
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
