import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/product_grid_shimmer.dart';
import '../../../products/presentation/pages/product_details_page.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/guest_service.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/auth_prompt_dialog.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRUCE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildMarketOverview(),
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const ProductGridShimmer();
                } else if (state is ProductLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<ProductCubit>().fetchAllProducts(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.groups.length,
                      itemBuilder: (context, index) {
                        final group = state.groups[index];
                        final product = group.lowestPriceVariant;
                        return ProductCard(
                          product: product,
                          onTap: () async {
                            final authState = context.read<AuthCubit>().state;
                            if (authState.user.isGuest) {
                              final guestService = sl<GuestService>();
                              if (guestService.isLimitReached) {
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => const AuthPromptDialog(),
                                  );
                                }
                                return;
                              }
                              await guestService.incrementAction();
                            }

                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsPage(
                                  product: product,
                                  group: group,
                                ),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fade(delay: (index * 50).ms)
                            .slideY(begin: 0.1, end: 0);
                      },
                    ),
                  );
                } else if (state is ProductError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onSubmitted: (query) => context.read<ProductCubit>().searchProducts(query),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.translate('search_hint'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.filter_list),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    ).animate().fade().slideX();
  }

  Widget _buildMarketOverview() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildOverviewItem(AppLocalizations.of(context)!.translate('gold'), '3,850 EGP', Icons.brightness_high, Colors.amber),
          _buildOverviewItem(AppLocalizations.of(context)!.translate('usd'), '48.50 EGP', Icons.attach_money, Colors.green),
          _buildOverviewItem(AppLocalizations.of(context)!.translate('poultry'), '85 EGP', Icons.restaurant, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String title, String price, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
