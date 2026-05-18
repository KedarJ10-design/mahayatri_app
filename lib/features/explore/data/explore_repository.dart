import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_logger.dart';
import '../../../services/supabase_service.dart';
import '../domain/destination.dart';
import '../domain/guide.dart';
import '../domain/stay.dart';

/// Repository for fetching explore content: destinations, guides, stays.
class ExploreRepository {
  final SupabaseClient _client;

  ExploreRepository(this._client);

  // ── Destinations ──

  /// Fetch featured destinations for the home screen.
  Future<List<Destination>> getFeaturedDestinations({int limit = 6}) async {
    try {
      final data = await _client
          .from('destinations')
          .select()
          .eq('is_featured', true)
          .eq('is_active', true)
          .order('avg_rating', ascending: false)
          .limit(limit);

      return data.map((json) => Destination.fromJson(json)).toList();
    } catch (e, st) {
      log.e('Failed to fetch featured destinations', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Fetch destinations by category.
  Future<List<Destination>> getDestinationsByCategory(
    String category, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = await _client
          .from('destinations')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('avg_rating', ascending: false)
          .range(offset, offset + limit - 1);

      return data.map((json) => Destination.fromJson(json)).toList();
    } catch (e, st) {
      log.e('Failed to fetch destinations', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Search destinations by name.
  Future<List<Destination>> searchDestinations(String query) async {
    try {
      final data = await _client
          .from('destinations')
          .select()
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .order('avg_rating', ascending: false)
          .limit(20);

      return data.map((json) => Destination.fromJson(json)).toList();
    } catch (e, st) {
      log.e('Failed to search destinations', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Get a single destination by ID.
  Future<Destination> getDestination(String id) async {
    try {
      final data = await _client
          .from('destinations')
          .select()
          .eq('id', id)
          .single();

      return Destination.fromJson(data);
    } catch (e, st) {
      log.e('Failed to fetch destination', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── Guides ──

  /// Fetch top-rated guides for home screen.
  Future<List<Guide>> getTopGuides({int limit = 6}) async {
    try {
      final data = await _client
          .from('guides')
          .select()
          .eq('is_verified', true)
          .eq('is_available', true)
          .order('avg_rating', ascending: false)
          .limit(limit);

      return data.map((json) => Guide.fromJson(json)).toList();
    } catch (e, st) {
      log.e('Failed to fetch top guides', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Fetch guides by district.
  Future<List<Guide>> getGuidesByDistrict(String district) async {
    try {
      final data = await _client
          .from('guides')
          .select()
          .eq('district', district)
          .eq('is_available', true)
          .order('avg_rating', ascending: false);

      return data.map((json) => Guide.fromJson(json)).toList();
    } catch (e, st) {
      log.e('Failed to fetch guides by district', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Get a single guide by ID.
  Future<Guide> getGuide(String id) async {
    try {
      final data = await _client
          .from('guides')
          .select()
          .eq('id', id)
          .single();

      return Guide.fromJson(data);
    } catch (e, st) {
      log.e('Failed to fetch guide', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── Stays ──

  /// Fetch popular stays for home screen.
  Future<List<Stay>> getPopularStays({int limit = 6}) async {
    try {
      final data = await _client
          .from('stays')
          .select()
          .eq('is_available', true)
          .order('avg_rating', ascending: false)
          .limit(limit);

      return data.map((json) => Stay.fromJson(json)).toList();
    } catch (e, st) {
      log.e('Failed to fetch popular stays', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Search stays with filters.
  Future<List<Stay>> searchStays({
    String? district,
    String? type,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('stays')
          .select()
          .eq('is_available', true);

      if (district != null) query = query.eq('district', district);
      if (type != null) query = query.eq('type', type);
      if (maxPrice != null) {
        query = query.lte('price_per_night', maxPrice);
      }

      final data = await query
          .order('avg_rating', ascending: false)
          .range(offset, offset + limit - 1);

      return data.map((json) => Stay.fromJson(json)).toList();
    } catch (e, st) {
      log.e('Failed to search stays', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Get a single stay by ID.
  Future<Stay> getStay(String id) async {
    try {
      final data = await _client
          .from('stays')
          .select()
          .eq('id', id)
          .single();

      return Stay.fromJson(data);
    } catch (e, st) {
      log.e('Failed to fetch stay', error: e, stackTrace: st);
      rethrow;
    }
  }
}

/// Provider for the ExploreRepository.
final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ExploreRepository(client);
});
