/// App-wide constants
abstract final class AppConstants {
  // ── App Info ──
  static const String appName = 'Mahayatri';
  static const String appTagline = 'Your Smart Travel Companion';
  static const String appVersion = '1.0.0';

  // ── Pagination ──
  static const int defaultPageSize = 20;
  static const int searchDebounceMs = 500;

  // ── Cache ──
  static const String hiveCacheBox = 'mahayatri_cache';
  static const String hiveUserBox = 'mahayatri_user';
  static const Duration cacheExpiry = Duration(hours: 24);

  // ── Animation Durations ──
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);

  // ── Validation ──
  static const int minPasswordLength = 8;
  static const int maxBioLength = 500;
  static const int otpLength = 6;
  static const int maxReviewLength = 500;

  // ── Assets Paths ──
  static const String imagesPath = 'assets/images';
  static const String iconsPath = 'assets/icons';
  static const String lottiePath = 'assets/lottie';

  // ── Supabase Tables ──
  static const String tableProfiles = 'profiles';
  static const String tableGuides = 'guides';
  static const String tableStays = 'stays';
  static const String tableVendors = 'vendors';
  static const String tableBookings = 'bookings';
  static const String tableReviews = 'reviews';
  static const String tableItineraries = 'itineraries';
  static const String tableMessages = 'messages';
  static const String tableConversations = 'conversations';
  static const String tableNotifications = 'notifications';

  // ── Storage Buckets ──
  static const String bucketAvatars = 'avatars';
  static const String bucketReviews = 'review-photos';
  static const String bucketStays = 'stay-images';
  static const String bucketChat = 'chat-media';
  static const String bucketDocuments = 'guide-documents';
}
