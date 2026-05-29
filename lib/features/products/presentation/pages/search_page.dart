import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../domain/entities/product.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/product_card.dart';
import 'product_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final PageController _pageController;
  Timer? _autoSlideTimer;

  bool _expanded = false;

  // Full store names matching the API's store_name field.
  static const _stores = <String>[
    'Jumia Egypt',
    'Amazon Egypt',
    'Carrefour Egypt',
    'Noon Egypt',
  ];

  // API-compatible category values.
  static const _categoryApiValues = <String?>[
    null,
    'Electronics',
    'Fashion',
    'Home',
    'Sports',
  ];

  // Translation keys for category display labels.
  static const _categoryKeys = <String>[
    'cat_all',
    'cat_electronics',
    'cat_fashion',
    'cat_home',
    'cat_sports',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<SearchCubit>().state.query);
    _focusNode = FocusNode();
    _pageController = PageController();

    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() => _expanded = _focusNode.hasFocus);
    });

    context.read<SearchCubit>().searchFirstPage();

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final cubitState = context.read<SearchCubit>().state;
      final pageCount = cubitState.loadedPagesCount;
      if (pageCount < 2 || !_pageController.hasClients) return;
      final next = (cubitState.currentPageIndex + 1) % pageCount;
      context.read<SearchCubit>().setCurrentPageIndex(next);
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.tr('search', fallback: 'Search')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              padding: EdgeInsets.fromLTRB(16, _expanded ? 8 : 16, 16, 12),
              child: Column(
                children: [
                  _searchBar(context),
                  const SizedBox(height: 10),
                  _filtersRow(context),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<SearchCubit, SearchState>(
                listener: (context, state) {
                  final msg = state.errorMessage;
                  if (msg != null && msg.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                builder: (context, state) {
                  if (state.isLoadingFirstPage) return _loadingShimmer();

                  if (state.pages.isEmpty) {
                    return Center(
                      child: Text(
                        context.tr('no_results_found', fallback: 'No results found'),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: state.pages.length,
                          onPageChanged: (i) {
                            context.read<SearchCubit>().setCurrentPageIndex(i);
                            if (i >= state.pages.length - 1) {
                              context.read<SearchCubit>().loadNextPage();
                            }
                          },
                          itemBuilder: (context, index) =>
                              _productsGrid(state.pages[index]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: state.pages.length,
                                effect: WormEffect(
                                  dotHeight: 7,
                                  dotWidth: 7,
                                  spacing: 6,
                                  activeDotColor:
                                      Theme.of(context).colorScheme.primary,
                                  dotColor: Colors.grey.shade400,
                                ),
                                onDotClicked: (i) {
                                  context
                                      .read<SearchCubit>()
                                      .setCurrentPageIndex(i);
                                  _pageController.animateToPage(
                                    i,
                                    duration: const Duration(milliseconds: 450),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                            if (state.isLoadingNextPage) ...[
                              const SizedBox(width: 12),
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Hero(
      tag: 'search_bar',
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.35
                      : 0.06,
                ),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  // Support Arabic/English keyboard input natively.
                  onChanged: (v) => context.read<SearchCubit>().setQuery(v),
                  onSubmitted: (_) =>
                      context.read<SearchCubit>().searchFirstPage(),
                  decoration: InputDecoration(
                    hintText: context.tr('search_hint'),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _controller.clear();
                  context.read<SearchCubit>().setQuery('');
                  context.read<SearchCubit>().searchFirstPage();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filtersRow(BuildContext context) {
    // Resolve translated category labels aligned with _categoryApiValues.
    final categoryItems = List.generate(_categoryKeys.length, (i) {
      return DropdownMenuItem<String?>(
        value: _categoryApiValues[i],
        child: Text(context.tr(_categoryKeys[i])),
      );
    });

    final storeItems = [
      DropdownMenuItem<String?>(
        value: null,
        child: Text(context.tr('any', fallback: 'Any')),
      ),
      ..._stores.map((s) => DropdownMenuItem<String?>(value: s, child: Text(s))),
    ];

    return Row(
      children: [
        Expanded(
          child: _filterContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: context.select((SearchCubit c) => c.state.storeName),
                hint: Text(context.tr('store', fallback: 'Store')),
                items: storeItems,
                onChanged: (v) {
                  context.read<SearchCubit>().setStore(v);
                  context.read<SearchCubit>().searchFirstPage();
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _filterContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: context.select((SearchCubit c) => c.state.category),
                hint: Text(context.tr('filter_category', fallback: 'Category')),
                items: categoryItems,
                onChanged: (v) {
                  context.read<SearchCubit>().setCategory(v);
                  context.read<SearchCubit>().searchFirstPage();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterContainer({required Widget child}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _loadingShimmer() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 12),
          ShimmerLoader(width: double.infinity, height: 18),
          SizedBox(height: 10),
          ShimmerLoader(width: double.infinity, height: 18),
          SizedBox(height: 10),
          ShimmerLoader(width: double.infinity, height: 18),
        ],
      ),
    );
  }

  Widget _productsGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          ),
        );
      },
    );
  }
}
