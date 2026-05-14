import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';

// Placeholder screens — will be replaced with real screens as we build features
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

/// Main router configuration using GoRouter with declarative routing.
///
/// Route guards (auth, role-based) are handled via redirect callbacks.
/// Shell routes provide persistent bottom navigation.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth Flow (no bottom nav) ──
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Splash'),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Onboarding'),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Sign Up'),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Forgot Password'),
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
          // Tab 1: Home
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Home'),
          ),
          // Tab 2: Explore
          GoRoute(
            path: RouteNames.explore,
            name: 'explore',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Explore'),
          ),
          // Tab 3: AI Planner
          GoRoute(
            path: RouteNames.planner,
            name: 'planner',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'AI Planner'),
          ),
          // Tab 4: Bookings
          GoRoute(
            path: RouteNames.bookings,
            name: 'bookings',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Bookings'),
          ),
          // Tab 5: Profile
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
        path: '${RouteNames.vendorDetail}/:id',
        name: 'vendorDetail',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Vendor: ${state.pathParameters['id']}',
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
        path: '${RouteNames.chatConversation}/:id',
        name: 'chatConversation',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Chat: ${state.pathParameters['id']}',
        ),
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
            const SizedBox(height: 8),
            Text(state.error.toString()),
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
///
/// This wraps the 5 main tabs: Home, Explore, AI Planner, Bookings, Profile.
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
