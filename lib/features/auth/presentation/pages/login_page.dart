import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truce_app/features/auth/presentation/pages/signup_page.dart';
import 'package:truce_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:truce_app/features/auth/presentation/pages/phone_login_page.dart';
import 'package:truce_app/features/main/presentation/pages/nav_page.dart';

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
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const NavPage()),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Section (Green)
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', width: 100, height: 100),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome to Truce',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Track prices. Save money.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Login Form
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v!.contains('@') ? null : 'Invalid email',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v!.length < 6 ? 'Too short' : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          if (state.status == AuthStatus.loading) {
                            return const CircularProgressIndicator();
                          }
                          return ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().logInWithEmail(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                            },
                            child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(height: 40),
                      // Social Logins
                      _buildSocialButton(
                        label: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        onPressed: () => context.read<AuthCubit>().logInWithGoogle(),
                      ),
                      const SizedBox(height: 12),
                      _buildSocialButton(
                        label: 'Continue with Phone',
                        icon: Icons.phone_android,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PhoneLoginPage()));
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context.read<AuthCubit>().logInAnonymously(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Continue as Guest'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
