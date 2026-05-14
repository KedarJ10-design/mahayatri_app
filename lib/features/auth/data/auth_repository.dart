import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/supabase_service.dart';
import '../domain/user_profile.dart';

/// Repository handling all authentication and profile operations.
///
/// Uses Supabase Auth for authentication and the `profiles` table
/// for user profile data.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // ── Auth State ──

  /// Current authenticated user (nullable).
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Sign Up ──

  /// Sign up with email and password.
  /// Returns the created user or throws on failure.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      log.i('User signed up: ${response.user?.id}');
      return response;
    } catch (e, st) {
      log.e('Sign up failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── Sign In ──

  /// Sign in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      log.i('User signed in: ${response.user?.id}');
      return response;
    } catch (e, st) {
      log.e('Sign in failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── Password Reset ──

  /// Send password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      log.i('Password reset email sent to $email');
    } catch (e, st) {
      log.e('Password reset failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── Sign Out ──

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      log.i('User signed out');
    } catch (e, st) {
      log.e('Sign out failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── Profile Operations ──

  /// Fetch the current user's profile from the `profiles` table.
  Future<UserProfile?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    try {
      final data = await _client
          .from(AppConstants.tableProfiles)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e, st) {
      log.e('Get profile failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Update the user's profile.
  Future<UserProfile> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? bio,
    String? avatarUrl,
    bool? isOnboarded,
  }) async {
    final userId = currentUser!.id;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (isOnboarded != null) updates['is_onboarded'] = isOnboarded;

    try {
      final data = await _client
          .from(AppConstants.tableProfiles)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      log.i('Profile updated for user $userId');
      return UserProfile.fromJson(data);
    } catch (e, st) {
      log.e('Update profile failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}

/// Provider for the AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});
