import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../core/config/env_config.dart';
import '../../core/utils/app_logger.dart';

/// Generated itinerary model.
class TripItinerary {
  final String title;
  final String summary;
  final List<DayPlan> days;
  final List<String> tips;
  final String estimatedBudget;

  TripItinerary({
    required this.title,
    required this.summary,
    required this.days,
    required this.tips,
    required this.estimatedBudget,
  });

  factory TripItinerary.fromJson(Map<String, dynamic> json) {
    return TripItinerary(
      title: json['title'] as String? ?? 'Your Maharashtra Trip',
      summary: json['summary'] as String? ?? '',
      days: (json['days'] as List<dynamic>?)
              ?.map((d) => DayPlan.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      tips: (json['tips'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      estimatedBudget: json['estimated_budget'] as String? ?? 'N/A',
    );
  }
}

class DayPlan {
  final int day;
  final String title;
  final List<Activity> activities;

  DayPlan({
    required this.day,
    required this.title,
    required this.activities,
  });

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      day: json['day'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      activities: (json['activities'] as List<dynamic>?)
              ?.map((a) => Activity.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Activity {
  final String time;
  final String name;
  final String description;
  final String? location;
  final String? estimatedCost;
  final String category; // transport, food, sightseeing, stay, activity

  Activity({
    required this.time,
    required this.name,
    required this.description,
    this.location,
    this.estimatedCost,
    this.category = 'sightseeing',
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      time: json['time'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String?,
      estimatedCost: json['estimated_cost'] as String?,
      category: json['category'] as String? ?? 'sightseeing',
    );
  }
}

/// Service for generating trip itineraries using Gemini AI.
class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: EnvConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topP: 0.95,
        maxOutputTokens: 4096,
        responseMimeType: 'application/json',
      ),
    );
  }

  /// Generate a trip itinerary based on user preferences.
  Future<TripItinerary> generateItinerary({
    required int days,
    required String budget,
    required List<String> interests,
    String? prompt,
  }) async {
    final systemPrompt = '''
You are Mahayatri AI — an expert travel planner specializing exclusively in Maharashtra, India.
Create a detailed, personalized $days-day itinerary based on the user's preferences.

User Preferences:
- Duration: $days days
- Budget: $budget
- Interests: ${interests.isEmpty ? 'General tourism' : interests.join(', ')}
${prompt != null && prompt.isNotEmpty ? '- Additional notes: $prompt' : ''}

IMPORTANT RULES:
1. Only suggest destinations in Maharashtra
2. Be specific with real place names, restaurants, and attractions
3. Include local hidden gems, not just tourist spots
4. Provide realistic time estimates and costs in INR (₹)
5. Consider travel time between locations

Return a valid JSON object with this exact structure:
{
  "title": "Trip title",
  "summary": "A brief 2-3 sentence summary of the trip",
  "days": [
    {
      "day": 1,
      "title": "Day title (e.g., 'Exploring Old Mumbai')",
      "activities": [
        {
          "time": "09:00 AM",
          "name": "Activity name",
          "description": "1-2 sentence description",
          "location": "Specific location/address",
          "estimated_cost": "₹500",
          "category": "sightseeing"
        }
      ]
    }
  ],
  "tips": ["Practical travel tip 1", "Tip 2", "Tip 3"],
  "estimated_budget": "₹15,000 - ₹20,000 per person"
}

Valid categories: transport, food, sightseeing, stay, activity, shopping
Provide 4-6 activities per day. Include breakfast, lunch, and dinner suggestions.
''';

    try {
      log.i('Generating itinerary: $days days, $budget budget');
      final response = await _model.generateContent([
        Content.text(systemPrompt),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      // Parse JSON - handle potential markdown wrapping
      String jsonStr = text.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      }
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }
      jsonStr = jsonStr.trim();

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return TripItinerary.fromJson(json);
    } catch (e, st) {
      log.e('Gemini AI generation failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}

/// Provider for GeminiService singleton.
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

/// Provider for generating itineraries with state management.
final itineraryProvider =
    StateNotifierProvider<ItineraryNotifier, AsyncValue<TripItinerary?>>(
  (ref) => ItineraryNotifier(ref.read(geminiServiceProvider)),
);

class ItineraryNotifier extends StateNotifier<AsyncValue<TripItinerary?>> {
  final GeminiService _service;

  ItineraryNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> generate({
    required int days,
    required String budget,
    required List<String> interests,
    String? prompt,
  }) async {
    state = const AsyncValue.loading();
    try {
      final itinerary = await _service.generateItinerary(
        days: days,
        budget: budget,
        interests: interests,
        prompt: prompt,
      );
      state = AsyncValue.data(itinerary);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
