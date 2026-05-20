import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:truce_app/core/di/injection_container.dart' as di;
import 'package:truce_app/core/theme/app_colors.dart';
import 'package:truce_app/features/home/presentation/pages/home_page.dart';
import 'package:truce_app/features/products/presentation/pages/explore_page.dart';
import 'package:truce_app/features/account/presentation/pages/account_page.dart';
import 'package:truce_app/features/coupons/presentation/pages/coupons_page.dart';
import 'package:truce_app/features/market/presentation/cubit/market_cubit.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Allow HomePage to trigger tab switches (e.g. search bar tapping tab 2)
  void switchTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MarketCubit>(),
      child: Scaffold(
        body: BottomBar(
          icon: (width, height) => Center(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.expand_less,
                color: Colors.white,
                size: width,
              ),
            ),
          ),
          layout: BottomBarLayout(
            width: MediaQuery.of(context).size.width * 0.88,
            borderRadius: BorderRadius.circular(500),
            alignment: Alignment.bottomCenter,
          ),
          theme: BottomBarThemeData(
            barDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(500),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
          ),
          showIcon: true,
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomePage(onSwitchTab: switchTab),
              const CouponsPage(),
              const ExplorePage(),
              const AccountPage(),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            tabs: [
              _buildTab(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildTab(1, Icons.confirmation_number_outlined, Icons.confirmation_number, 'Coupons'),
              _buildTab(2, Icons.search_outlined, Icons.search, 'Search'),
              _buildTab(3, Icons.person_outline, Icons.person, 'Account'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _tabController.index == index;

    return Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors.primary : Colors.grey.shade500,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey.shade500,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 3,
              width: 3,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
