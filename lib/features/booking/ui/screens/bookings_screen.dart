import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/core.dart';
import '../../domain/booking.dart';
import '../../providers/booking_providers.dart';

/// Bookings list screen with status filter tabs.
class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  static const _tabs = [
    (null, 'All'),
    ('pending', 'Pending'),
    ('confirmed', 'Confirmed'),
    ('completed', 'Completed'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(bookingTabProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Tab Chips ──
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingXs,
              ),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTheme.spacingSm),
              itemBuilder: (context, index) {
                final (value, label) = _tabs[index];
                final isActive = activeTab == value;

                return ChoiceChip(
                  label: Text(label),
                  selected: isActive,
                  onSelected: (_) {
                    ref.read(bookingTabProvider.notifier).state = value;
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color:
                        isActive ? AppColors.primary : AppColors.textPrimaryLight,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                );
              },
            ),
          ),

          // ── Booking List ──
          Expanded(
            child: bookingsAsync.when(
              data: (bookings) => bookings.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(myBookingsProvider);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        itemCount: bookings.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppTheme.spacingSm),
                        itemBuilder: (context, index) =>
                            _BookingCard(booking: bookings[index]),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.grey400),
                    const SizedBox(height: AppTheme.spacingSm),
                    const Text('Failed to load bookings'),
                    TextButton(
                      onPressed: () => ref.invalidate(myBookingsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppColors.grey300,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No bookings yet',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Start exploring and book your\nfirst adventure!',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual booking card with status badge, dates, and price.
class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Image
          Container(
            width: 100,
            height: 120,
            color: AppColors.grey100,
            child: booking.entityImage != null
                ? Image.network(
                    booking.entityImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image_outlined, color: AppColors.grey400),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.hotel_rounded,
                        size: 32, color: AppColors.grey400),
                  ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.entityName ?? booking.entityType,
                          style: AppTypography.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusBadge(booking.status),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Dates
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${dateFormat.format(booking.checkIn)} → ${dateFormat.format(booking.checkOut)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Guests + Price
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Text(
                        '${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${booking.totalPrice.toInt()}',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final (color, bgColor) = switch (status) {
      'pending' => (AppColors.warning, AppColors.warning.withValues(alpha: 0.12)),
      'confirmed' => (AppColors.info, AppColors.info.withValues(alpha: 0.12)),
      'completed' => (AppColors.success, AppColors.success.withValues(alpha: 0.12)),
      'cancelled' => (AppColors.error, AppColors.error.withValues(alpha: 0.12)),
      'refunded' => (AppColors.grey600, AppColors.grey200),
      _ => (AppColors.grey600, AppColors.grey200),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
