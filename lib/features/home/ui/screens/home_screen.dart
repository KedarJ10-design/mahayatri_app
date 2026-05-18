import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../shared/widgets/content_card.dart';
import '../../../../shared/widgets/section_widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../explore/domain/guide.dart';
import '../../providers/home_providers.dart';

/// Main home screen — the first thing users see after login.
///
/// Sections:
/// 1. Greeting + search bar
/// 2. Quick category filters
/// 3. Featured destinations carousel
/// 4. Top guides horizontal list
/// 5. Popular stays horizontal list
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final firstName = profile?.fullName?.split(' ').first ?? 'Traveler';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(featuredDestinationsProvider);
            ref.invalidate(topGuidesProvider);
            ref.invalidate(popularStaysProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: _buildHeader(context, firstName),
              ),

              // ── Search Bar ──
              SliverToBoxAdapter(
                child: _buildSearchBar(context),
              ),

              // ── Category Chips ──
              SliverToBoxAdapter(
                child: _buildCategoryChips(ref),
              ),

              // ── Featured Destinations ──
              SliverToBoxAdapter(
                child: _buildFeaturedSection(context, ref),
              ),

              // ── Top Guides ──
              SliverToBoxAdapter(
                child: _buildGuidesSection(context, ref),
              ),

              // ── Popular Stays ──
              SliverToBoxAdapter(
                child: _buildStaysSection(context, ref),
              ),

              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header with greeting ──
  Widget _buildHeader(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: AppTypography.headlineMedium,
                ),
              ],
            ),
          ),
          // Notification bell
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(RouteNames.notifications),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  // ── Search Bar ──
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: GestureDetector(
        onTap: () => context.push(RouteNames.explore),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.grey400,
                size: 22,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  'Search destinations, guides, stays...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category Chips ──
  Widget _buildCategoryChips(WidgetRef ref) {
    final categories = ref.watch(destinationCategoriesProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingSm),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return ActionChip(
            label: Text('${cat.emoji} ${cat.label}'),
            onPressed: () {
              // TODO: Navigate to filtered explore
              context.push(RouteNames.explore);
            },
            backgroundColor: AppColors.grey50,
            side: const BorderSide(color: AppColors.grey200),
            labelStyle: AppTypography.labelMedium,
          );
        },
      ),
    );
  }

  // ── Featured Destinations ──
  Widget _buildFeaturedSection(BuildContext context, WidgetRef ref) {
    final destinationsAsync = ref.watch(featuredDestinationsProvider);

    return Column(
      children: [
        const SizedBox(height: AppTheme.spacingMd),
        SectionHeader(
          title: 'Featured Destinations',
          actionText: 'See All',
          onActionTap: () => context.push(RouteNames.explore),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SizedBox(
          height: 240,
          child: destinationsAsync.when(
            data: (destinations) => destinations.isEmpty
                ? const Center(child: Text('No featured destinations yet'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                    ),
                    itemCount: destinations.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppTheme.spacingSm),
                    itemBuilder: (context, index) {
                      final dest = destinations[index];
                      return ContentCard(
                        imageUrl: dest.imageUrl,
                        title: dest.name,
                        subtitle: dest.district ?? dest.category,
                        rating: dest.avgRating,
                        reviewCount: dest.reviewCount,
                        tag: dest.isFeatured ? '✨ Featured' : null,
                        width: 200,
                        height: 240,
                        onTap: () => context.push(
                          '${RouteNames.guideDetail}/${dest.id}',
                        ),
                      );
                    },
                  ),
            loading: () => _buildShimmerRow(),
            error: (err, _) => SectionError(
              message: 'Could not load destinations',
              onRetry: () => ref.invalidate(featuredDestinationsProvider),
            ),
          ),
        ),
      ],
    );
  }

  // ── Top Guides ──
  Widget _buildGuidesSection(BuildContext context, WidgetRef ref) {
    final guidesAsync = ref.watch(topGuidesProvider);

    return Column(
      children: [
        const SizedBox(height: AppTheme.spacingMd),
        SectionHeader(
          title: 'Top Guides',
          actionText: 'See All',
          onActionTap: () => context.push(RouteNames.explore),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SizedBox(
          height: 200,
          child: guidesAsync.when(
            data: (guides) => guides.isEmpty
                ? const Center(child: Text('No guides yet'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                    ),
                    itemCount: guides.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppTheme.spacingSm),
                    itemBuilder: (context, index) {
                      final guide = guides[index];
                      return _buildGuideCard(context, guide);
                    },
                  ),
            loading: () => _buildShimmerRow(height: 200),
            error: (err, _) => SectionError(
              message: 'Could not load guides',
              onRetry: () => ref.invalidate(topGuidesProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard(BuildContext context, Guide guide) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.guideDetail}/${guide.id}'),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppTheme.spacingSm),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
              backgroundImage: guide.avatarUrl != null
                  ? NetworkImage(guide.avatarUrl!)
                  : null,
              child: guide.avatarUrl == null
                  ? Text(
                      guide.displayName[0].toUpperCase(),
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // Name
            Text(
              guide.displayName,
              style: AppTypography.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            // District
            if (guide.district != null) ...[
              const SizedBox(height: 2),
              Text(
                guide.district!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),

            // Rating + verified badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (guide.isVerified)
                  const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: AppColors.info,
                  ),
                if (guide.isVerified) const SizedBox(width: 4),
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 2),
                Text(
                  guide.avgRating.toStringAsFixed(1),
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Popular Stays ──
  Widget _buildStaysSection(BuildContext context, WidgetRef ref) {
    final staysAsync = ref.watch(popularStaysProvider);

    return Column(
      children: [
        const SizedBox(height: AppTheme.spacingMd),
        SectionHeader(
          title: 'Popular Stays',
          actionText: 'See All',
          onActionTap: () => context.push(RouteNames.explore),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SizedBox(
          height: 240,
          child: staysAsync.when(
            data: (stays) => stays.isEmpty
                ? const Center(child: Text('No stays yet'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                    ),
                    itemCount: stays.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppTheme.spacingSm),
                    itemBuilder: (context, index) {
                      final stay = stays[index];
                      return ContentCard(
                        imageUrl: stay.imageUrl,
                        title: stay.name,
                        subtitle: '${stay.type} • ${stay.district ?? ''}',
                        rating: stay.avgRating,
                        reviewCount: stay.reviewCount,
                        price: '₹${stay.pricePerNight.toInt()}/night',
                        width: 200,
                        height: 240,
                        onTap: () => context.push(
                          '${RouteNames.stayDetail}/${stay.id}',
                        ),
                      );
                    },
                  ),
            loading: () => _buildShimmerRow(),
            error: (err, _) => SectionError(
              message: 'Could not load stays',
              onRetry: () => ref.invalidate(popularStaysProvider),
            ),
          ),
        ),
      ],
    );
  }

  // ── Loading Shimmer ──
  Widget _buildShimmerRow({double height = 240}) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingSm),
      itemBuilder: (_, __) => ShimmerCard(width: 200, height: height),
    );
  }
}
