import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/utils/app_logger.dart';
import '../data/auth_repository.dart';
import '../domain/user_profile.dart';

/// Represents the current authentication state of the application.
///
/// Named `AppAuthState` to avoid naming collision with Supabase's `AuthState`.
sealed class AppAuthState {
  const AppAuthState();
}

class AuthInitial extends AppAuthState {
  const AuthInitial();
}

class AuthLoading extends AppAuthState {
  const AuthLoading();
}

class Authenticated extends AppAuthState {
  final UserProfile profile;
  const Authenticated(this.profile);
}

class Unauthenticated extends AppAuthState {
  const Unauthenticated();
}

class AuthError extends AppAuthState {
  final String message;
  const AuthError(this.message);
}

/// Main auth state notifier managing the full authentication lifecycle.
///
/// Listens to Supabase auth state changes and auto-fetches the profile
/// when a user signs in.
class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthRepository _repo;
  StreamSubscription<supa.AuthState>? _authSub;

  AuthNotifier(this._repo) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    // Check if already logged in
    if (_repo.currentUser != null) {
      _loadProfile();
    } else {
      state = const Unauthenticated();
    }

    // Listen for auth state changes
    _authSub = _repo.authStateChanges.listen((event) {
      final eventType = event.event;
      log.i('Auth event: $eventType');

      switch (eventType) {
        case supa.AuthChangeEvent.signedIn:
        case supa.AuthChangeEvent.tokenRefreshed:
        case supa.AuthChangeEvent.userUpdated:
          _loadProfile();
        case supa.AuthChangeEvent.signedOut:
          state = const Unauthenticated();
        case supa.AuthChangeEvent.initialSession:
          if (event.session != null) {
            _loadProfile();
          } else {
            state = const Unauthenticated();
          }
        default:
          break;
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repo.getProfile();
      if (profile != null) {
        state = Authenticated(profile);
      } else {
        // Profile not yet created (might happen on first sign up)
        state = const Unauthenticated();
      }
    } catch (e) {
      log.e('Failed to load profile', error: e);
      state = AuthError(e.toString());
    }
  }

  // ── Actions ──

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AuthLoading();
    try {
      await _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      // Auth listener will handle state change → _loadProfile
    } on supa.AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
    } catch (e) {
      state = AuthError('Something went wrong. Please try again.');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      await _repo.signInWithEmail(email: email, password: password);
      // Auth listener will handle state change → _loadProfile
    } on supa.AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
    } catch (e) {
      state = AuthError('Something went wrong. Please try again.');
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AuthLoading();
    try {
      await _repo.resetPassword(email);
      // Don't change auth state — just show success in the UI
      state = const Unauthenticated();
    } on supa.AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
    } catch (e) {
      state = AuthError('Something went wrong. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await _repo.signOut();
      // Auth listener will set state to Unauthenticated
    } catch (e) {
      log.e('Sign out error', error: e);
    }
  }

  Future<void> markOnboarded() async {
    try {
      final updatedProfile = await _repo.updateProfile(isOnboarded: true);
      state = Authenticated(updatedProfile);
    } catch (e) {
      log.e('Failed to mark onboarded', error: e);
    }
  }

  /// Maps raw Supabase auth error messages to user-friendly strings.
  String _mapAuthError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (msg.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('weak password')) {
      return 'Password is too weak. Use at least 8 characters.';
    }
    return message;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

/// Provider for the auth state.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

/// Convenience provider to check if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider) is Authenticated;
});

/// Convenience provider to get current user profile (nullable).
final userProfileProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is Authenticated) return authState.profile;
  return null;
});
