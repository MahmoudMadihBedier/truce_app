import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/main/presentation/pages/nav_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  bool _timerElapsed = false;
  bool _authResolved = false;
  AuthState? _resolvedAuthState;

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    // 2.5-second minimum timer
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _timerElapsed = true;
        _tryNavigate();
      }
    });

    // Listen to auth state
    final currentAuthState = context.read<AuthCubit>().state;
    if (currentAuthState.status != AuthStatus.unknown) {
      _authResolved = true;
      _resolvedAuthState = currentAuthState;
    }
  }

  void _tryNavigate() {
    if (!_timerElapsed || !_authResolved) return;
    if (!mounted) return;

    final authState = _resolvedAuthState ?? context.read<AuthCubit>().state;

    if (authState.status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState.status != AuthStatus.unknown) {
          _authResolved = true;
          _resolvedAuthState = authState;
          _tryNavigate();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Stack(
            children: [
              // Background decorative circles
              Positioned(
                right: -60,
                top: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: 100,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                            .animate()
                            .fade(duration: 700.ms)
                            .scale(
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 32),

                        // App name
                        const Text(
                          'Truce',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        )
                            .animate()
                            .fade(delay: 600.ms, duration: 500.ms)
                            .slideY(begin: 0.4, end: 0, curve: Curves.easeOut),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'COMPARE · SAVE · WIN',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                            .animate()
                            .fade(delay: 800.ms, duration: 500.ms),
                      ],
                    ),
                  ),

                  // Bottom section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                    child: Column(
                      children: [
                        // Progress bar
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            return Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: _progressController.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.accentOrange,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fade(delay: 1000.ms),

                        const SizedBox(height: 20),

                        Text(
                          "Egypt's #1 Price Aggregator",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        )
                            .animate()
                            .fade(delay: 1200.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
