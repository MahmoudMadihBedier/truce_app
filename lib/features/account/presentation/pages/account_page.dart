import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truce_app/core/localization/app_localizations.dart';
import 'package:truce_app/core/theme/app_colors.dart';
import 'package:truce_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truce_app/core/theme/settings_cubit.dart';
import 'package:truce_app/features/auth/presentation/pages/login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayName = user.displayName ??
        (user.isGuest
            ? context.tr('guest_user', fallback: 'Guest User')
            : context.tr('truce_user', fallback: 'Truce User'));

    final email = user.email ??
        (user.isGuest
            ? context.tr('browsing_as_guest', fallback: 'Browsing as guest')
            : '');

    final parts = displayName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : 'G';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                                      errorBuilder: (_, __, ___) =>
                                          _initialsAvatar(initials),
                                    ),
                                  )
                                : _initialsAvatar(initials),
                          ).animate().scale(
                              duration: 500.ms, curve: Curves.easeOutBack),

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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                context.tr('edit', fallback: 'Edit'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
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
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _statCard(context, context.tr('total_orders'), '0'),
                      const SizedBox(width: 10),
                      _statCard(context, context.tr('coupons_used'), '0'),
                      const SizedBox(width: 10),
                      _statCard(context, context.tr('total_saved'), '0 EGP'),
                    ],
                  ).animate().fade(delay: 250.ms).slideY(begin: 0.1, end: 0),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── PREFERENCES section ───────────────────────────────────
            _sectionLabel(context, context.tr('preferences').toUpperCase()),

            _settingsCard(context, [
              _prefsItem(
                context,
                icon: Icons.notifications_outlined,
                title: context.tr('price_alerts'),
                trailing: _greenChip(context,
                    context.tr('active_3', fallback: '3 active')),
              ),
              _divider(context),
              _prefsItem(
                context,
                icon: Icons.favorite_border,
                title: context.tr('wishlist'),
                trailing: Text(
                  context.tr('saved_0', fallback: '0 saved'),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                ),
              ),
              _divider(context),
              _prefsItem(
                context,
                icon: Icons.currency_exchange,
                title: context.tr('currency_display'),
                trailing: Text(
                  context.tr('currency_egp', fallback: 'Egyptian Pound (EGP)'),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ),
              _divider(context),
              // Dark Mode
              _prefsItem(
                context,
                icon: isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
                title: context.tr('dark_mode'),
                trailing: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (ctx, settings) => Switch(
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (_) => ctx.read<SettingsCubit>().toggleTheme(),
                  ),
                ),
              ),
              _divider(context),
              // Language
              _prefsItem(
                context,
                icon: Icons.language_outlined,
                title: context.tr('language'),
                trailing: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (ctx, settings) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settings.locale.languageCode == 'en'
                            ? ctx.tr('english', fallback: 'English')
                            : ctx.tr('arabic', fallback: 'العربية'),
                        style: TextStyle(
                          color: Theme.of(ctx).textTheme.bodySmall?.color,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Theme.of(ctx).textTheme.bodySmall?.color,
                      ),
                    ],
                  ),
                ),
                onTap: () => _showLanguageDialog(context),
              ),
            ]).animate().fade(delay: 350.ms),

            const SizedBox(height: 12),

            // ── PLATFORMS section ─────────────────────────────────────
            _sectionLabel(context, context.tr('platforms').toUpperCase()),

            _settingsCard(context, [
              _prefsItem(context,
                  leading: _platformAvatar('A', const Color(0xFFFF9900)),
                  title: 'Amazon Egypt',
                  trailing: _greenChip(context, context.tr('on', fallback: 'On'))),
              _divider(context),
              _prefsItem(context,
                  leading: _platformAvatar('N', const Color(0xFFFEC52E)),
                  title: 'Noon Egypt',
                  trailing: _greenChip(context, context.tr('on', fallback: 'On'))),
              _divider(context),
              _prefsItem(context,
                  leading: _platformAvatar('J', const Color(0xFFE74C3C)),
                  title: 'Jumia Egypt',
                  trailing: _greenChip(context, context.tr('on', fallback: 'On'))),
              _divider(context),
              _prefsItem(context,
                  leading: _platformAvatar('C', const Color(0xFF003CB6)),
                  title: 'Carrefour Egypt',
                  trailing: _greenChip(context, context.tr('on', fallback: 'On'))),
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
                  backgroundColor:
                      isDark ? const Color(0xFF3A1A1A) : Colors.red.shade50,
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  context.tr('log_out', fallback: 'Log Out'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _statCard(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.bodySmall?.color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingsCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _prefsItem(
    BuildContext context, {
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
                Icon(icon, size: 22,
                    color: Theme.of(context).textTheme.bodySmall?.color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _greenChip(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkPaleGreen : AppColors.paleGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? AppColors.lightGreen : AppColors.primary,
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
        title: Text(
          context.tr('select_language', fallback: 'Select Language'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
              title: Text(context.tr('english', fallback: 'English')),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🇪🇬', style: TextStyle(fontSize: 22)),
              title: Text(context.tr('arabic', fallback: 'العربية')),
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
