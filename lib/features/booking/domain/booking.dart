import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'entity_type') required String entityType,
    @JsonKey(name: 'entity_id') required String entityId,
    @JsonKey(name: 'entity_name') String? entityName,
    @JsonKey(name: 'entity_image') String? entityImage,
    required String status,
    @JsonKey(name: 'check_in') required DateTime checkIn,
    @JsonKey(name: 'check_out') required DateTime checkOut,
    @JsonKey(name: 'guest_count') @Default(1) int guestCount,
    @JsonKey(name: 'total_price') required double totalPrice,
    @JsonKey(name: 'special_requests') String? specialRequests,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
