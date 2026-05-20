import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truce_app/core/theme/settings_cubit.dart';
import 'package:truce_app/core/localization/app_localizations.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null ? Icon(Icons.person, size: 50, color: primaryColor) : null,
            ),
            const SizedBox(height: 16),
            Text(user.displayName ?? 'Guest User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user.email ?? (user.isGuest ? 'Guest Access' : ''), style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _buildSection(
              context,
              title: 'Settings',
              items: [
                _buildSettingsItem(
                  context,
                  icon: Icons.language,
                  title: 'Language',
                  trailing: BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, state) {
                      return Text(state.locale.languageCode == 'en' ? 'English' : 'العربية');
                    },
                  ),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  trailing: BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, state) {
                      return Switch(
                        value: state.themeMode == ThemeMode.dark,
                        onChanged: (_) => context.read<SettingsCubit>().toggleTheme(),
                      );
                    },
                  ),
                ),
              ],
            ),
            _buildSection(
              context,
              title: 'Support',
              items: [
                _buildSettingsItem(context, icon: Icons.help_outline, title: 'Help Center'),
                _buildSettingsItem(context, icon: Icons.privacy_tip_outlined, title: 'Privacy Policy'),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () => context.read<AuthCubit>().logOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
