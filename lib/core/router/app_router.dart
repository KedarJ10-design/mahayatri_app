import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';

// Auth screens
import '../../features/auth/ui/screens/splash_screen.dart';
import '../../features/auth/ui/screens/onboarding_screen.dart';
import '../../features/auth/ui/screens/login_screen.dart';
import '../../features/auth/ui/screens/signup_screen.dart';
import '../../features/auth/ui/screens/forgot_password_screen.dart';

// Placeholder for screens not yet built
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main router configuration using GoRouter.
///
/// Auth screens are standalone routes (no bottom nav).
/// Main app screens use ShellRoute for persistent bottom navigation.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth Flow (no bottom nav) ──
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.otpVerify,
        name: 'otpVerify',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'OTP Verification'),
      ),

      // ── Main App (with bottom navigation via ShellRoute) ──
      ShellRoute(
        builder: (context, state, child) {
          return _MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Home'),
          ),
          GoRoute(
            path: RouteNames.explore,
            name: 'explore',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Explore'),
          ),
          GoRoute(
            path: RouteNames.planner,
            name: 'planner',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'AI Planner'),
          ),
          GoRoute(
            path: RouteNames.bookings,
            name: 'bookings',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Bookings'),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Profile'),
          ),
        ],
      ),

      // ── Detail Screens (no bottom nav) ──
      GoRoute(
        path: '${RouteNames.guideDetail}/:id',
        name: 'guideDetail',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Guide: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '${RouteNames.stayDetail}/:id',
        name: 'stayDetail',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Stay: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '${RouteNames.bookingDetail}/:id',
        name: 'bookingDetail',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Booking: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: RouteNames.chat,
        name: 'chatList',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Chat'),
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Notifications'),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Settings'),
      ),
      GoRoute(
        path: RouteNames.safety,
        name: 'safety',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Safety Center'),
      ),
    ],

    // Global error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Main shell widget providing persistent bottom navigation bar.
class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(RouteNames.home)) return 0;
    if (location.startsWith(RouteNames.explore)) return 1;
    if (location.startsWith(RouteNames.planner)) return 2;
    if (location.startsWith(RouteNames.bookings)) return 3;
    if (location.startsWith(RouteNames.profile)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(RouteNames.home);
            case 1:
              context.go(RouteNames.explore);
            case 2:
              context.go(RouteNames.planner);
            case 3:
              context.go(RouteNames.bookings);
            case 4:
              context.go(RouteNames.profile);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'AI Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
