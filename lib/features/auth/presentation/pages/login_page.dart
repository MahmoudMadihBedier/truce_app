import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/auth_cubit.dart';
import '../../../home/presentation/pages/nav_page.dart';
import '../../../../core/localization/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const NavPage()),
            );
          }
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ).animate().fade().scale(),
                const SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context)!.translate('welcome_back'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E35),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.translate('track_prices'),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 400.ms),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('email'),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!value.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                      ).animate().fade(delay: 600.ms).slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ).animate().fade(delay: 700.ms).slideX(begin: -0.1, end: 0),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Login logic
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.translate('login')),
                ).animate().fade(delay: 800.ms).scale(),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.read<AuthCubit>().logInWithGoogle(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.g_mobiledata, size: 30),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.translate('continue_with_google')),
                    ],
                  ),
                ).animate().fade(delay: 900.ms).scale(),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.read<AuthCubit>().logInAnonymously(),
                  child: Text(AppLocalizations.of(context)!.translate('continue_as_guest')),
                ).animate().fade(delay: 1000.ms),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.translate('dont_have_account')),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        AppLocalizations.of(context)!.translate('sign_up'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
