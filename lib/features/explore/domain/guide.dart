import 'package:freezed_annotation/freezed_annotation.dart';

part 'guide.freezed.dart';
part 'guide.g.dart';

@freezed
abstract class Guide with _$Guide {
  const factory Guide({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'display_name') required String displayName,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @Default(['Hindi', 'Marathi']) List<String> languages,
    @Default([]) List<String> specializations,
    @JsonKey(name: 'experience_years') @Default(0) int experienceYears,
    @JsonKey(name: 'hourly_rate') double? hourlyRate,
    @JsonKey(name: 'daily_rate') double? dailyRate,
    String? district,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'is_available') @Default(true) bool isAvailable,
    @JsonKey(name: 'avg_rating') @Default(0) double avgRating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'total_trips') @Default(0) int totalTrips,
  }) = _Guide;

  factory Guide.fromJson(Map<String, dynamic> json) => _$GuideFromJson(json);
}
