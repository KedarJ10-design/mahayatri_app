import 'package:freezed_annotation/freezed_annotation.dart';

part 'destination.freezed.dart';
part 'destination.g.dart';

@freezed
abstract class Destination with _$Destination {
  const factory Destination({
    required String id,
    required String name,
    required String slug,
    String? description,
    @JsonKey(name: 'short_description') String? shortDescription,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'cover_url') String? coverUrl,
    double? latitude,
    double? longitude,
    String? district,
    @Default('general') String category,
    @Default([]) List<String> tags,
    @JsonKey(name: 'avg_rating') @Default(0) double avgRating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Destination;

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);
}
