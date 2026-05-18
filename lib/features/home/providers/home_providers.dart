import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../explore/data/explore_repository.dart';
import '../../explore/domain/destination.dart';
import '../../explore/domain/guide.dart';
import '../../explore/domain/stay.dart';

/// Home screen data providers.
///
/// Each provider is independent so sections load independently
/// and errors in one don't block the others.

/// Featured destinations for the hero carousel.
final featuredDestinationsProvider =
    FutureProvider<List<Destination>>((ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.getFeaturedDestinations(limit: 5);
});

/// Top-rated verified guides.
final topGuidesProvider = FutureProvider<List<Guide>>((ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.getTopGuides(limit: 6);
});

/// Popular stays.
final popularStaysProvider = FutureProvider<List<Stay>>((ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.getPopularStays(limit: 6);
});

/// Destination categories for quick filters.
final destinationCategoriesProvider = Provider<List<_Category>>((ref) {
  return const [
    _Category('fort', '🏰', 'Forts'),
    _Category('beach', '🏖️', 'Beaches'),
    _Category('hill_station', '⛰️', 'Hill Stations'),
    _Category('temple', '🛕', 'Temples'),
    _Category('waterfall', '💧', 'Waterfalls'),
    _Category('wildlife', '🐆', 'Wildlife'),
    _Category('heritage', '🏛️', 'Heritage'),
  ];
});

/// Simple data class for category chips.
class _Category {
  final String key;
  final String emoji;
  final String label;

  const _Category(this.key, this.emoji, this.label);
}
