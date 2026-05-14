import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../providers/auth_provider.dart';

/// Splash screen shown on app launch.
///
/// Displays the Mahayatri branding while initializing the app,
/// then routes based on authentication state.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate after splash duration
    Future.delayed(AppConstants.splashDuration, _navigate);
  }

  void _navigate() {
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);

    switch (authState) {
      case Authenticated(profile: final profile):
        if (profile.isOnboarded) {
          context.go(RouteNames.home);
        } else {
          context.go(RouteNames.onboarding);
        }
      case Unauthenticated():
      case AuthError():
        context.go(RouteNames.login);
      default:
        // Still loading — wait a bit more
        Future.delayed(const Duration(seconds: 1), _navigate);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
                child: const Icon(
                  Icons.terrain_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              // App Name
              Text(
                'Mahayatri',
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              // Tagline
              Text(
                AppConstants.appTagline,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
