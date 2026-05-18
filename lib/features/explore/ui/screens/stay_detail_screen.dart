import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../data/explore_repository.dart';
import '../../domain/stay.dart';

/// Provider to fetch a single stay by ID.
final stayDetailProvider =
    FutureProvider.autoDispose.family<Stay, String>((ref, id) {
  return ref.read(exploreRepositoryProvider).getStay(id);
});

/// Full stay detail screen with image gallery, amenities, pricing.
class StayDetailScreen extends ConsumerWidget {
  final String id;
  const StayDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(stayDetailProvider(id));

    return Scaffold(
      body: detailAsync.when(
        data: (stay) => _StayContent(stay: stay),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.grey400),
              const SizedBox(height: AppTheme.spacingSm),
              Text('Failed to load stay', style: AppTypography.bodyLarge),
              TextButton(
                onPressed: () => ref.invalidate(stayDetailProvider(id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StayContent extends StatelessWidget {
  final Stay stay;
  const _StayContent({required this.stay});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // ── Image Gallery ──
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  stay.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                  ),
                ),
                background: stay.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: stay.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.grey200),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.grey200,
                                child: const Icon(Icons.hotel_rounded,
                                    size: 48, color: AppColors.grey400)),
                      )
                    : Container(
                        color: AppColors.grey200,
                        child: const Icon(Icons.hotel_rounded,
                            size: 48, color: AppColors.grey400),
                      ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_outline_rounded),
                  onPressed: () {},
                ),
              ],
            ),

            // ── Content ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type + Location
                    Row(
                      children: [
                        _chip(stay.type.toUpperCase()),
                        const SizedBox(width: 8),
                        if (stay.district != null) ...[
                          Icon(Icons.location_on_outlined,
                              size: 16, color: AppColors.grey500),
                          const SizedBox(width: 4),
                          Text(
                            stay.district!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Max guests
                        Icon(Icons.people_outlined,
                            size: 16, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Text(
                          '${stay.maxGuests} guests',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSm),

                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.warning, size: 22),
                        const SizedBox(width: 4),
                        Text(
                          stay.avgRating.toStringAsFixed(1),
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${stay.reviewCount} reviews)',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMd),

                    // Description
                    if (stay.description != null) ...[
                      Text('About', style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        stay.description!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],

                    // Amenities
                    if (stay.amenities.isNotEmpty) ...[
                      Text('Amenities', style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: AppTheme.spacingSm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: stay.amenities.map((a) {
                          final icon = _amenityIcon(a);
                          return Chip(
                            avatar: Icon(icon, size: 16),
                            label: Text(a),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],

                    // Image Gallery (if multiple images)
                    if (stay.images.length > 1) ...[
                      Text('Gallery', style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: AppTheme.spacingSm),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: stay.images.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) => ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm),
                            child: CachedNetworkImage(
                              imageUrl: stay.images[index],
                              width: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],

                    // Extra space for bottom bar
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Bottom Price + Book Bar ──
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${stay.pricePerNight.toInt()}',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'per night',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        '${RouteNames.bookStay}/${stay.id}',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _amenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi')) return Icons.wifi_rounded;
    if (lower.contains('parking')) return Icons.local_parking_rounded;
    if (lower.contains('pool')) return Icons.pool_rounded;
    if (lower.contains('ac') || lower.contains('air')) return Icons.ac_unit_rounded;
    if (lower.contains('breakfast')) return Icons.free_breakfast_rounded;
    if (lower.contains('kitchen')) return Icons.kitchen_rounded;
    if (lower.contains('tv')) return Icons.tv_rounded;
    if (lower.contains('gym')) return Icons.fitness_center_rounded;
    if (lower.contains('spa')) return Icons.spa_rounded;
    return Icons.check_circle_outline_rounded;
  }
}
