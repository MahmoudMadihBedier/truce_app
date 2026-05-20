import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truce_app/core/theme/app_colors.dart';
import 'package:truce_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truce_app/core/theme/settings_cubit.dart';
import 'package:truce_app/features/auth/presentation/pages/login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final displayName = user.displayName ?? (user.isGuest ? 'Guest User' : 'Truce User');
    final email = user.email ?? (user.isGuest ? 'Browsing as guest' : '');

    // Build initials
    final parts = displayName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : 'G';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Green header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.midGreen],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Avatar
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: user.photoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      user.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _initialsAvatar(initials),
                                    ),
                                  )
                                : _initialsAvatar(initials),
                          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                          const SizedBox(height: 12),

                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fade(delay: 150.ms),

                          const SizedBox(height: 4),

                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ).animate().fade(delay: 200.ms),
                        ],
                      ),

                      // Edit button
                      if (!user.isGuest)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Stats row ─────────────────────────────────────────────
            Container(
              color: AppColors.primary,
              child: Container(
                margin: const EdgeInsets.only(top: 0),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _statCard('Total Orders', '0'),
                      const SizedBox(width: 10),
                      _statCard('Coupons Used', '0'),
                      const SizedBox(width: 10),
                      _statCard('Total Saved', '0 EGP'),
                    ],
                  ).animate().fade(delay: 250.ms).slideY(begin: 0.1, end: 0),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── PREFERENCES section ───────────────────────────────────
            _sectionLabel('PREFERENCES'),

            _settingsCard([
              _prefsItem(
                icon: Icons.notifications_outlined,
                title: 'Price Alerts',
                trailing: _greenChip('3 active'),
              ),
              _divider(),
              _prefsItem(
                icon: Icons.favorite_border,
                title: 'Wishlist',
                trailing: Text(
                  '0 saved',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
              _divider(),
              _prefsItem(
                icon: Icons.currency_exchange,
                title: 'Currency Display',
                trailing: Text(
                  'Egyptian Pound (EGP)',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
              _divider(),
              // Dark Mode
              Builder(
                builder: (context) => _prefsItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  trailing: BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (ctx, settings) => Switch(
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (_) => ctx.read<SettingsCubit>().toggleTheme(),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ),
              ),
              _divider(),
              // Language
              Builder(
                builder: (context) => _prefsItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  trailing: BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (ctx, settings) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          settings.locale.languageCode == 'en' ? 'English' : 'العربية',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                  onTap: () => _showLanguageDialog(context),
                ),
              ),
            ]).animate().fade(delay: 350.ms),

            const SizedBox(height: 12),

            // ── PLATFORMS section ─────────────────────────────────────
            _sectionLabel('PLATFORMS'),

            _settingsCard([
              _prefsItem(
                leading: _platformAvatar('A', const Color(0xFFFF9900)),
                title: 'Amazon Egypt',
                trailing: _greenChip('On'),
              ),
              _divider(),
              _prefsItem(
                leading: _platformAvatar('N', const Color(0xFFFEC52E)),
                title: 'Noon Egypt',
                trailing: _greenChip('On'),
              ),
              _divider(),
              _prefsItem(
                leading: _platformAvatar('J', const Color(0xFFE74C3C)),
                title: 'Jumia Egypt',
                trailing: _greenChip('On'),
              ),
              _divider(),
              _prefsItem(
                leading: _platformAvatar('C', const Color(0xFF003CB6)),
                title: 'Carrefour Egypt',
                trailing: _greenChip('On'),
              ),
            ]).animate().fade(delay: 450.ms),

            const SizedBox(height: 20),

            // ── Log Out ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () async {
                  await context.read<AuthCubit>().logOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ).animate().fade(delay: 500.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _initialsAvatar(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.shade100,
    );
  }

  Widget _prefsItem({
    IconData? icon,
    Widget? leading,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            leading ??
                Icon(icon, size: 22, color: Colors.grey.shade600),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _greenChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _platformAvatar(String letter, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
              title: const Text('English'),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🇪🇬', style: TextStyle(fontSize: 22)),
              title: const Text('العربية'),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('ar'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
