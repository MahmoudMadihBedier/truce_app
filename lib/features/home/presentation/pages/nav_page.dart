import 'package:flutter/material.dart';
import 'home_page.dart';
import '../../../coupons/presentation/pages/coupons_page.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../products/presentation/pages/explore_page.dart';
import '../../../../core/localization/app_localizations.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ExplorePage(),
    const CouponsPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: AppLocalizations.of(context)!.translate('home')),
          NavigationDestination(icon: const Icon(Icons.category_outlined), selectedIcon: const Icon(Icons.category), label: AppLocalizations.of(context)!.translate('explore')),
          NavigationDestination(icon: const Icon(Icons.confirmation_number_outlined), selectedIcon: const Icon(Icons.confirmation_number), label: AppLocalizations.of(context)!.translate('coupons')),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: AppLocalizations.of(context)!.translate('account')),
        ],
      ),
    );
  }
}
