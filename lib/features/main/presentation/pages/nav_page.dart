import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:truce_app/features/home/presentation/pages/home_page.dart';
import 'package:truce_app/features/products/presentation/pages/explore_page.dart';
import 'package:truce_app/features/account/presentation/pages/account_page.dart';
import 'package:truce_app/features/coupons/presentation/pages/coupons_page.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: BottomBar(
        icon: (width, height) => Center(
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
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
            width: MediaQuery.of(context).size.width * 0.9,
            borderRadius: BorderRadius.circular(500),
            alignment: Alignment.bottomCenter,
        ),
        theme: BottomBarThemeData(
            barDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(500),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            )
        ),
        showIcon: true,
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomePage(),
            ExplorePage(),
            CouponsPage(),
            AccountPage(),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.transparent,
          tabs: [
            _buildTab(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildTab(1, Icons.explore_outlined, Icons.explore, 'Explore'),
            _buildTab(2, Icons.confirmation_number_outlined, Icons.confirmation_number, 'Coupons'),
            _buildTab(3, Icons.person_outline, Icons.person, 'Account'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _tabController.index == index;
    final primaryColor = Theme.of(context).primaryColor;

    return Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? primaryColor : Colors.grey,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 4,
              width: 4,
              decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
