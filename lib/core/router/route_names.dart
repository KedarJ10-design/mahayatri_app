/// Centralized route name constants.
///
/// Using constants prevents typos in route paths and makes
/// refactoring routes safe across the entire codebase.
abstract final class RouteNames {
  // ── Auth Flow ──
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerify = '/otp-verify';

  // ── Main Tabs ──
  static const String home = '/home';
  static const String explore = '/explore';
  static const String planner = '/planner';
  static const String bookings = '/bookings';
  static const String profile = '/profile';

  // ── Detail Screens ──
  static const String destinationDetail = '/destination';
  static const String guideDetail = '/guide';
  static const String stayDetail = '/stay';
  static const String vendorDetail = '/vendor';
  static const String bookingDetail = '/booking';

  // ── Booking Flow ──
  static const String bookStay = '/book-stay';
  static const String bookGuide = '/book-guide';

  // ── Chat ──
  static const String chat = '/chat';
  static const String chatConversation = '/chat/conversation';

  // ── Other ──
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String savedPlaces = '/saved-places';
  static const String rewards = '/rewards';
  static const String safety = '/safety';
  static const String help = '/help';
  static const String faq = '/faq';

  // ── Guide Dashboard ──
  static const String guideDashboard = '/guide-dashboard';
  static const String guideAnalytics = '/guide-analytics';

  // ── Admin ──
  static const String adminDashboard = '/admin';
  static const String adminVerification = '/admin/verification';
  static const String adminUsers = '/admin/users';
}
