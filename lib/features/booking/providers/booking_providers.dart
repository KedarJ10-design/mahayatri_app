import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/booking_repository.dart';
import '../domain/booking.dart';

/// Active tab filter for bookings list.
final bookingTabProvider = StateProvider<String?>((ref) => null);

/// Bookings list provider — refreshes on tab change.
final myBookingsProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  final statusFilter = ref.watch(bookingTabProvider);
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getMyBookings(statusFilter: statusFilter);
});
