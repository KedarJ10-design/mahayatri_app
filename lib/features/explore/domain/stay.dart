import 'package:freezed_annotation/freezed_annotation.dart';

part 'stay.freezed.dart';
part 'stay.g.dart';

@freezed
abstract class Stay with _$Stay {
  const factory Stay({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    String? description,
    @JsonKey(name: 'short_description') String? shortDescription,
    @Default('homestay') String type,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default([]) List<String> images,
    @JsonKey(name: 'price_per_night') required double pricePerNight,
    @JsonKey(name: 'max_guests') @Default(2) int maxGuests,
    String? district,
    String? address,
    double? latitude,
    double? longitude,
    @Default([]) List<String> amenities,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'is_available') @Default(true) bool isAvailable,
    @JsonKey(name: 'avg_rating') @Default(0) double avgRating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
  }) = _Stay;

  factory Stay.fromJson(Map<String, dynamic> json) => _$StayFromJson(json);
}
