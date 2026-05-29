import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:truce_app/core/localization/app_localizations.dart';
import 'package:truce_app/core/theme/app_colors.dart';
import 'package:truce_app/features/products/presentation/cubit/product_cubit.dart';
import 'package:truce_app/features/products/presentation/cubit/search_cubit.dart';
import 'package:truce_app/features/products/presentation/widgets/product_card.dart';
import 'package:truce_app/features/products/presentation/pages/product_details_page.dart';
import 'package:truce_app/features/products/presentation/pages/search_page.dart';
import 'package:truce_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truce_app/features/market/presentation/cubit/market_cubit.dart';
import 'package:truce_app/features/market/domain/entities/market_rate.dart';
import 'package:truce_app/features/market/presentation/cubit/market_state.dart';
import 'package:truce_app/features/market/domain/entities/market_instrument.dart';
import 'package:truce_app/features/market/presentation/widgets/market_details_dialog.dart';
import 'package:truce_app/core/widgets/shimmer_loader.dart';
import 'package:truce_app/features/auth/presentation/widgets/auth_prompt_dialog.dart';

/// Category data: translation key, icon, API-compatible category value.
class _CategoryItem {
  final String translationKey;
  final IconData icon;
  final String? apiValue;

  const _CategoryItem({
    required this.translationKey,
    required this.icon,
    this.apiValue,
  });
}

class HomePage extends StatefulWidget {
  final void Function(int tabIndex)? onSwitchTab;

  const HomePage({super.key, this.onSwitchTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  PageController? _marketPageController;
  Timer? _marketAutoTimer;
  int _marketPageIndex = 0;

  late final TextEditingController _homeSearchController;

  static const _categoryItems = <_CategoryItem>[
    _CategoryItem(translationKey: 'cat_all', icon: Icons.apps_rounded),
    _CategoryItem(translationKey: 'cat_electronics', icon: Icons.devices_rounded, apiValue: 'Electronics'),
    _CategoryItem(translationKey: 'cat_fashion', icon: Icons.checkroom_rounded, apiValue: 'Fashion'),
    _CategoryItem(translationKey: 'cat_home', icon: Icons.home_outlined, apiValue: 'Home'),
    _CategoryItem(translationKey: 'cat_sports', icon: Icons.sports_soccer_outlined, apiValue: 'Sports'),
  ];

  @override
  void initState() {
    super.initState();
    _homeSearchController = TextEditingController();
    context.read<ProductCubit>().fetchAllProducts();
    context.read<MarketCubit>().fetchRates();

    Future.delayed(const Duration(seconds: 15), () {
      if (!mounted) return;
      final authState = context.read<AuthCubit>().state;
      if (authState.user.isGuest) {
        AuthPromptDialog.show(context);
      }
    });
  }

  @override
  void dispose() {
    _marketAutoTimer?.cancel();
    _marketPageController?.dispose();
    _homeSearchController.dispose();
    super.dispose();
  }

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('good_morning', fallback: 'Good morning');
    if (hour < 17) return context.tr('good_afternoon', fallback: 'Good afternoon');
    return context.tr('good_evening', fallback: 'Good evening');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final userName = user.displayName ?? user.email?.split('@')[0] ?? 'Guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.midGreen],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_greeting(context)}, 👋',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _appBarIconBtn(Icons.notifications_none),
                              const SizedBox(width: 10),
                              _appBarIconBtn(Icons.settings_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body content ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMarketOverview(),
                _buildSearchBar(),
                _buildCategoriesSection(isDark),
                _buildFlashSaleBanner(),
                _buildSectionHeader(
                  context.tr('featured_deals', fallback: 'Featured Deals'),
                  () {},
                ),
              ],
            ),
          ),

          _buildFeaturedGrid(),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _appBarIconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildMarketOverview() {
    return BlocConsumer<MarketCubit, MarketState>(
      listener: (context, state) {
        final message = state.errorMessage;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        _ensureMarketCarouselStarted();
        final rates = state.rates;
        _ensureMarketIndexInRange(rates.length);
        final controller = _marketPageController;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: rates.isEmpty
              ? const Row(
                  children: [
                    Expanded(child: ShimmerLoader(width: double.infinity, height: 102)),
                    SizedBox(width: 12),
                    Expanded(child: ShimmerLoader(width: double.infinity, height: 102)),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 102,
                      child: PageView.builder(
                        controller: controller,
                        itemCount: rates.length,
                        onPageChanged: (i) => _marketPageIndex = i,
                        itemBuilder: (context, i) {
                          final rate = rates[i];
                          final instrument = _instrumentForLabel(rate.label);
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  useRootNavigator: false,
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<MarketCubit>(),
                                    child: MarketDetailsDialog(
                                      instrument: instrument,
                                      title: rate.label,
                                    ),
                                  ),
                                );
                              },
                              child: _buildMarketCard(rate),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (controller != null)
                      SmoothPageIndicator(
                        controller: controller,
                        count: rates.length,
                        effect: WormEffect(
                          dotHeight: 7,
                          dotWidth: 7,
                          spacing: 6,
                          activeDotColor: AppColors.primary,
                          dotColor: Colors.grey.shade300,
                        ),
                        onDotClicked: (index) {
                          _marketPageIndex = index;
                          controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                  ],
                ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.08, end: 0);
      },
    );
  }

  void _ensureMarketCarouselStarted() {
    _marketPageController ??= PageController(viewportFraction: 0.62);
    _marketAutoTimer ??= Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final controller = _marketPageController;
      if (controller == null) return;
      final count = context.read<MarketCubit>().state.rates.length;
      if (count < 2 || !controller.hasClients) return;
      _marketPageIndex = (_marketPageIndex + 1) % count;
      controller.animateToPage(
        _marketPageIndex,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    });
  }

  void _ensureMarketIndexInRange(int count) {
    if (count <= 0 || _marketPageIndex < count) return;
    _marketPageIndex = 0;
    final controller = _marketPageController;
    if (controller == null || !controller.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !controller.hasClients) return;
      controller.jumpToPage(0);
    });
  }

  MarketInstrument _instrumentForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('gold') && l.contains('21')) return MarketInstrument.gold21k;
    if (l.contains('gold') && l.contains('18')) return MarketInstrument.gold18k;
    if (l.contains('gold')) return MarketInstrument.gold24k;
    return MarketInstrument.usd;
  }

  Widget _buildMarketCard(MarketRate rate) {
    final changeColor =
        rate.isUp ? AppColors.accentOrange : AppColors.lightGreen;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rate.label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rate.label.contains('Gold')
                ? '${rate.price.toStringAsFixed(0)} EGP'
                : '${rate.price.toStringAsFixed(2)} EGP',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                rate.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: changeColor,
                size: 12,
              ),
              const SizedBox(width: 3),
              Text(
                '${rate.changePercentage.abs().toStringAsFixed(2)}%',
                style: TextStyle(
                  color: changeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final scheme = Theme.of(context).colorScheme;
    return Hero(
      tag: 'search_bar',
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          child: Row(
            children: [
              Icon(Icons.search, color: scheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _homeSearchController,
                  readOnly: true,
                  onTap: () {
                    context
                        .read<SearchCubit>()
                        .setQuery(_homeSearchController.text);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchPage()),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: context.tr('search_hint'),
                    border: InputBorder.none,
                    hintStyle:
                        TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  context
                      .read<SearchCubit>()
                      .setQuery(_homeSearchController.text);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
                icon: Icon(
                  Icons.tune,
                  color: Theme.of(context).hintColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: 100.ms);
  }

  Widget _buildCategoriesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context.tr('categories', fallback: 'Categories'),
          () {},
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categoryItems.length,
            itemBuilder: (context, index) {
              final cat = _categoryItems[index];
              final isSelected = _selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategoryIndex = index);
                  context.read<SearchCubit>().setCategory(cat.apiValue);
                  context.read<SearchCubit>().searchFirstPage();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          cat.icon,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).iconTheme.color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr(cat.translationKey),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ).animate().fade(delay: 200.ms),
      ],
    );
  }

  Widget _buildFlashSaleBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.olive, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥',
                                style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('flash_sale'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('up_to_40_off',
                            fallback: 'Up to 40% off\nElectronics'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('across_platforms',
                            fallback: 'Across all 4 platforms'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => widget.onSwitchTab?.call(2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    elevation: 0,
                  ),
                  child: Text(
                    context.tr('shop_now', fallback: 'Shop Now'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              context.tr('see_all', fallback: 'See all'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedGrid() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildListDelegate(
                List.generate(4, (_) => ShimmerLoader.productCard()),
              ),
            ),
          );
        }

        if (state is ProductLoaded) {
          final products = state.products.take(6).toList();
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  final group = state.groups.firstWhere(
                    (g) => g.productName == product.name,
                    orElse: () => state.groups.first,
                  );
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsPage(product: product, group: group),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (index * 60).ms)
                      .slideY(begin: 0.08, end: 0);
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
