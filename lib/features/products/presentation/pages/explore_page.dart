import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../products/presentation/pages/product_details_page.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/product_grid_shimmer.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String? _selectedCategory;

  final List<String> _categories = [
    'Automotive',
    'Beauty & Health',
    'Electronics',
    'Grocery',
    'Home & Kitchen',
    'Fashion'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Categories')),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                      if (selected) {
                        // Fetch by category logic
                        // For now we use search as proxy
                        context.read<ProductCubit>().searchProducts(category);
                      } else {
                        context.read<ProductCubit>().fetchAllProducts();
                      }
                    },
                    selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const ProductGridShimmer();
                } else if (state is ProductLoaded) {
                  return GridView.builder(
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
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsPage(
                                product: product,
                                group: group,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(child: Text('Select a category to explore'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
