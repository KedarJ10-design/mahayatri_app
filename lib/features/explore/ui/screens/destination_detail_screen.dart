import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../data/explore_repository.dart';
import '../../domain/destination.dart';

/// Provider to fetch a single destination by ID.
final destinationDetailProvider =
    FutureProvider.autoDispose.family<Destination, String>((ref, id) {
  return ref.read(exploreRepositoryProvider).getDestination(id);
});

/// Full-screen destination detail page.
class DestinationDetailScreen extends ConsumerWidget {
  final String id;
  const DestinationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(destinationDetailProvider(id));

    return Scaffold(
      body: detailAsync.when(
        data: (dest) => _DestinationContent(destination: dest),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.grey400),
              const SizedBox(height: AppTheme.spacingSm),
              Text('Failed to load destination',
                  style: AppTypography.bodyLarge),
              TextButton(
                onPressed: () => ref.invalidate(destinationDetailProvider(id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationContent extends StatelessWidget {
  final Destination destination;
  const _DestinationContent({required this.destination});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Hero Image ──
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              destination.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
            ),
            background: destination.coverUrl != null || destination.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: destination.coverUrl ?? destination.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.grey200),
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.grey200,
                            child: const Icon(Icons.landscape_rounded,
                                size: 48, color: AppColors.grey400)),
                  )
                : Container(
                    color: AppColors.grey200,
                    child: const Icon(Icons.landscape_rounded,
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
                // Category + District
                Row(
                  children: [
                    _chip(destination.category.replaceAll('_', ' ').toUpperCase()),
                    if (destination.district != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Text(
                        destination.district!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
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
                      destination.avgRating.toStringAsFixed(1),
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${destination.reviewCount} reviews)',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),

                // Description
                if (destination.description != null) ...[
                  Text('About', style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    destination.description!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondaryLight,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],

                // Tags
                if (destination.tags.isNotEmpty) ...[
                  Text('Tags', style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: AppTheme.spacingSm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: destination.tags
                        .map((t) => _chip(t))
                        .toList(),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.directions_rounded, size: 20),
                        label: const Text('Directions'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.rate_review_outlined, size: 20),
                        label: const Text('Write Review'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXl),
              ],
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
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
