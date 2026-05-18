import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_logger.dart';
import '../../../services/supabase_service.dart';
import '../domain/booking.dart';

/// Repository for booking CRUD operations.
class BookingRepository {
  final SupabaseClient _client;

  BookingRepository(this._client);

  /// Create a new booking.
  Future<Booking> createBooking({
    required String entityType,
    required String entityId,
    required String entityName,
    String? entityImage,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestCount,
    required double totalPrice,
    String? specialRequests,
  }) async {
    try {
      final userId = _client.auth.currentUser!.id;

      final data = await _client
          .from('bookings')
          .insert({
            'user_id': userId,
            'entity_type': entityType,
            'entity_id': entityId,
            'entity_name': entityName,
            'entity_image': entityImage,
            'check_in': checkIn.toIso8601String().split('T').first,
            'check_out': checkOut.toIso8601String().split('T').first,
            'guest_count': guestCount,
            'total_price': totalPrice,
            'special_requests': specialRequests,
          })
          .select()
          .single();

      log.i('Booking created: ${data['id']}');
      return Booking.fromJson(data);
    } catch (e, st) {
      log.e('Create booking failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Get all bookings for the current user.
  Future<List<Booking>> getMyBookings({String? statusFilter}) async {
    try {
      var query = _client
          .from('bookings')
          .select()
          .eq('user_id', _client.auth.currentUser!.id);

      if (statusFilter != null) {
        query = query.eq('status', statusFilter);
      }

      final data = await query.order('created_at', ascending: false);

      return data.map((json) => Booking.fromJson(json)).toList();
    } catch (e, st) {
      log.e('Get bookings failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Get a single booking by ID.
  Future<Booking> getBooking(String id) async {
    try {
      final data = await _client
          .from('bookings')
          .select()
          .eq('id', id)
          .single();

      return Booking.fromJson(data);
    } catch (e, st) {
      log.e('Get booking failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Cancel a booking.
  Future<Booking> cancelBooking(String id, {String? reason}) async {
    try {
      final data = await _client
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
          })
          .eq('id', id)
          .select()
          .single();

      log.i('Booking cancelled: $id');
      return Booking.fromJson(data);
    } catch (e, st) {
      log.e('Cancel booking failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}

/// Provider for the BookingRepository.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return BookingRepository(client);
});
