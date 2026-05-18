import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/core.dart';
import '../../data/booking_repository.dart';
import '../../providers/booking_providers.dart';

/// Screen for creating a new booking (stay or guide).
class CreateBookingScreen extends ConsumerStatefulWidget {
  final String entityType; // 'stay' or 'guide'
  final String entityId;
  final String entityName;
  final String? entityImage;
  final double pricePerUnit; // per night (stay) or per day (guide)

  const CreateBookingScreen({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    this.entityImage,
    required this.pricePerUnit,
  });

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 2));
  int _guestCount = 1;
  final _specialRequestsController = TextEditingController();
  bool _isSubmitting = false;

  int get _nights => _checkOut.difference(_checkIn).inDays;
  double get _totalPrice => widget.pricePerUnit * _nights * _guestCount;

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn ? _checkIn : _checkOut;
    final firstDate = isCheckIn
        ? DateTime.now()
        : _checkIn.add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        // Ensure check-out is after check-in
        if (_checkOut.isBefore(_checkIn) ||
            _checkOut.isAtSameMomentAs(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  Future<void> _confirmBooking() async {
    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.createBooking(
        entityType: widget.entityType,
        entityId: widget.entityId,
        entityName: widget.entityName,
        entityImage: widget.entityImage,
        checkIn: _checkIn,
        checkOut: _checkOut,
        guestCount: _guestCount,
        totalPrice: _totalPrice,
        specialRequests: _specialRequestsController.text.trim().isNotEmpty
            ? _specialRequestsController.text.trim()
            : null,
      );

      // Refresh bookings list
      ref.invalidate(myBookingsProvider);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: AppColors.success,
        ),
        title: const Text('Booking Confirmed!'),
        content: Text(
          'Your booking for ${widget.entityName} has been placed.\n\n'
          'You\'ll receive a confirmation shortly.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(RouteNames.bookings);
            },
            child: const Text('View My Bookings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, y');
    final priceLabel =
        widget.entityType == 'stay' ? 'per night' : 'per day';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Now'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Entity Preview ──
            Container(
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
                  if (widget.entityImage != null)
                    Image.network(
                      widget.entityImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.grey200,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.grey400),
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      color: AppColors.grey200,
                      child: Icon(
                        widget.entityType == 'stay'
                            ? Icons.hotel_rounded
                            : Icons.person_rounded,
                        color: AppColors.grey400,
                        size: 32,
                      ),
                    ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.entityName,
                            style: AppTypography.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${widget.pricePerUnit.toInt()} $priceLabel',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // ── Dates ──
            Text('Select Dates', style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              children: [
                Expanded(
                  child: _DateCard(
                    label: 'Check-in',
                    date: dateFormat.format(_checkIn),
                    icon: Icons.login_rounded,
                    onTap: () => _pickDate(isCheckIn: true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: AppColors.grey400),
                ),
                Expanded(
                  child: _DateCard(
                    label: 'Check-out',
                    date: dateFormat.format(_checkOut),
                    icon: Icons.logout_rounded,
                    onTap: () => _pickDate(isCheckIn: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // ── Guest Count ──
            Text('Guests', style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: AppTheme.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outlined, color: AppColors.grey500),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      '$_guestCount guest${_guestCount > 1 ? 's' : ''}',
                      style: AppTypography.bodyLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: _guestCount > 1
                        ? () => setState(() => _guestCount--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: AppColors.primary,
                  ),
                  Text(
                    '$_guestCount',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: _guestCount < 10
                        ? () => setState(() => _guestCount++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // ── Special Requests ──
            Text('Special Requests', style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: AppTheme.spacingSm),
            TextField(
              controller: _specialRequestsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special requirements? (optional)',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.grey400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // ── Price Summary ──
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  _priceRow(
                    '₹${widget.pricePerUnit.toInt()} × $_nights ${widget.entityType == 'stay' ? 'nights' : 'days'}',
                    '₹${(widget.pricePerUnit * _nights).toInt()}',
                  ),
                  if (_guestCount > 1)
                    _priceRow(
                      '× $_guestCount guests',
                      '₹${_totalPrice.toInt()}',
                    ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                      Text(
                        '₹${_totalPrice.toInt()}',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // ── Confirm Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Confirm Booking'),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              )),
          Text(value, style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}

/// Tappable date display card.
class _DateCard extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;
  final VoidCallback onTap;

  const _DateCard({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
