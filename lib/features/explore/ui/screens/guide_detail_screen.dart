import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../data/explore_repository.dart';
import '../../domain/guide.dart';

/// Provider to fetch a single guide by ID.
final guideDetailProvider =
    FutureProvider.autoDispose.family<Guide, String>((ref, id) {
  return ref.read(exploreRepositoryProvider).getGuide(id);
});

/// Full guide profile detail screen.
class GuideDetailScreen extends ConsumerWidget {
  final String id;
  const GuideDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(guideDetailProvider(id));

    return Scaffold(
      body: detailAsync.when(
        data: (guide) => _GuideContent(guide: guide),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.grey400),
              const SizedBox(height: AppTheme.spacingSm),
              Text('Failed to load guide', style: AppTypography.bodyLarge),
              TextButton(
                onPressed: () => ref.invalidate(guideDetailProvider(id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideContent extends StatelessWidget {
  final Guide guide;
  const _GuideContent({required this.guide});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── App Bar ──
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: guide.avatarUrl != null
                          ? CachedNetworkImageProvider(guide.avatarUrl!)
                          : null,
                      child: guide.avatarUrl == null
                          ? Text(
                              guide.displayName[0].toUpperCase(),
                              style: AppTypography.displaySmall.copyWith(
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    // Name + verified
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          guide.displayName,
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        if (guide.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              color: Colors.white, size: 22),
                        ],
                      ],
                    ),
                    if (guide.district != null)
                      Text(
                        guide.district!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Stats ──
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(AppTheme.spacingMd),
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat('${guide.avgRating}', '⭐ Rating'),
                _divider(),
                _stat('${guide.experienceYears}y', 'Experience'),
                _divider(),
                _stat('${guide.totalTrips}', 'Trips'),
                _divider(),
                _stat('${guide.reviewCount}', 'Reviews'),
              ],
            ),
          ),
        ),

        // ── Details ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bio
                if (guide.bio != null) ...[
                  Text('About', style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    guide.bio!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondaryLight,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],

                // Languages
                if (guide.languages.isNotEmpty) ...[
                  Text('Languages', style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: AppTheme.spacingSm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: guide.languages
                        .map((l) => Chip(
                              label: Text(l),
                              avatar: const Icon(Icons.translate_rounded, size: 16),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],

                // Specializations
                if (guide.specializations.isNotEmpty) ...[
                  Text('Specializations', style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: AppTheme.spacingSm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: guide.specializations
                        .map((s) => _infoChip(s))
                        .toList(),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],

                // Rates
                Text('Rates', style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: AppTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      if (guide.hourlyRate != null) ...[
                        Expanded(
                          child: Column(
                            children: [
                              Text('₹${guide.hourlyRate!.toInt()}',
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  )),
                              Text('per hour',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.grey500,
                                  )),
                            ],
                          ),
                        ),
                      ],
                      if (guide.hourlyRate != null && guide.dailyRate != null)
                        Container(width: 1, height: 40, color: AppColors.grey200),
                      if (guide.dailyRate != null) ...[
                        Expanded(
                          child: Column(
                            children: [
                              Text('₹${guide.dailyRate!.toInt()}',
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  )),
                              Text('per day',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.grey500,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Book CTA
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      '${RouteNames.bookGuide}/${guide.id}',
                    ),
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: const Text('Book This Guide'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            )),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: AppColors.grey200);

  Widget _infoChip(String label) {
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
}
