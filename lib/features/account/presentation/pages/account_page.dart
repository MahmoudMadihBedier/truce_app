import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (user.isGuest) ...[
                const Card(
                  color: Colors.amberAccent,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'You are in Guest Mode',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Sign in to save favorites and track prices.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  child: const Text('Sign In / Create Account'),
                ),
              ] else ...[
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.displayName ?? user.email ?? 'User'),
                  subtitle: Text(user.email ?? ''),
                ),
                const Divider(),
                const ListTile(leading: Icon(Icons.favorite_border), title: Text('My Favorites'), trailing: Icon(Icons.chevron_right)),
                const ListTile(leading: Icon(Icons.notifications_outlined), title: Text('Price Alerts'), trailing: Icon(Icons.chevron_right)),
                const ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings'), trailing: Icon(Icons.chevron_right)),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    context.read<AuthCubit>().logOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  child: const Text('Logout'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
