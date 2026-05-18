import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../shared/widgets/content_card.dart';
import '../../../../shared/widgets/section_widgets.dart';
import '../../data/explore_repository.dart';
import '../../domain/destination.dart';

/// Active search query provider.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results provider — debounced, triggers on query change.
final searchResultsProvider =
    FutureProvider.autoDispose<List<Destination>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  // Small debounce
  await Future.delayed(const Duration(milliseconds: 300));
  if (ref.watch(searchQueryProvider) != query) return [];

  final repo = ref.read(exploreRepositoryProvider);
  return repo.searchDestinations(query);
});

/// Active category filter.
final activeCategoryProvider = StateProvider<String?>((ref) => null);

/// Destinations filtered by category.
final categoryDestinationsProvider =
    FutureProvider.autoDispose<List<Destination>>((ref) async {
  final category = ref.watch(activeCategoryProvider);
  if (category == null) return [];

  final repo = ref.read(exploreRepositoryProvider);
  return repo.getDestinationsByCategory(category);
});

/// Explore screen with search + category filters + results grid.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  static const _categories = [
    ('fort', '🏰', 'Forts'),
    ('beach', '🏖️', 'Beaches'),
    ('hill_station', '⛰️', 'Hill Stations'),
    ('temple', '🛕', 'Temples'),
    ('waterfall', '💧', 'Waterfalls'),
    ('wildlife', '🐆', 'Wildlife'),
    ('heritage', '🏛️', 'Heritage'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final activeCategory = ref.watch(activeCategoryProvider);
    final isSearching = searchQuery.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search destinations...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
              ),
            ),

            // ── Category Chips ──
            if (!isSearching)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                  ),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppTheme.spacingSm),
                  itemBuilder: (context, index) {
                    final (key, emoji, label) = _categories[index];
                    final isActive = activeCategory == key;

                    return ChoiceChip(
                      label: Text('$emoji $label'),
                      selected: isActive,
                      onSelected: (selected) {
                        ref.read(activeCategoryProvider.notifier).state =
                            selected ? key : null;
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textPrimaryLight,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: AppTheme.spacingSm),

            // ── Results ──
            Expanded(
              child: isSearching
                  ? _buildSearchResults()
                  : activeCategory != null
                      ? _buildCategoryResults()
                      : _buildDefaultView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = ref.watch(searchResultsProvider);

    return results.when(
      data: (destinations) => destinations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 56, color: AppColors.grey300),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'No destinations found',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          : _buildGrid(destinations),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => SectionError(
        message: 'Search failed',
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
    );
  }

  Widget _buildCategoryResults() {
    final results = ref.watch(categoryDestinationsProvider);

    return results.when(
      data: (destinations) => destinations.isEmpty
          ? Center(
              child: Text(
                'No destinations in this category yet',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            )
          : _buildGrid(destinations),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => SectionError(
        message: 'Could not load destinations',
        onRetry: () => ref.invalidate(categoryDestinationsProvider),
      ),
    );
  }

  Widget _buildDefaultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_rounded, size: 72, color: AppColors.grey300),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Search or pick a category\nto discover destinations',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Destination> destinations) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final dest = destinations[index];
        return ContentCard(
          imageUrl: dest.imageUrl,
          title: dest.name,
          subtitle: dest.district,
          rating: dest.avgRating,
          reviewCount: dest.reviewCount,
          tag: dest.isFeatured ? '✨ Featured' : null,
          width: double.infinity,
          height: double.infinity,
          onTap: () => context.push(
            '${RouteNames.guideDetail}/${dest.id}',
          ),
        );
      },
    );
  }
}
