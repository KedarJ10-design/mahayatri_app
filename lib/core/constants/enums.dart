/// User roles for role-based access control
enum UserRole {
  traveler,
  guide,
  vendor,
  admin;

  /// Parse role from string (database value)
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.traveler,
    );
  }
}

/// Booking status lifecycle
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  refunded;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => BookingStatus.pending,
    );
  }

  bool get isActive =>
      this == BookingStatus.confirmed || this == BookingStatus.inProgress;

  bool get isFinal =>
      this == BookingStatus.completed ||
      this == BookingStatus.cancelled ||
      this == BookingStatus.refunded;
}

/// Entity types for polymorphic bookings
enum EntityType {
  guide,
  stay,
  vendor,
  activity;

  static EntityType fromString(String value) {
    return EntityType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => EntityType.guide,
    );
  }
}

/// Message types for chat
enum MessageType {
  text,
  image,
  location,
  bookingRef,
  system;

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => MessageType.text,
    );
  }
}

/// Notification types
enum NotificationType {
  booking,
  message,
  safety,
  promotion,
  system;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => NotificationType.system,
    );
  }
}

/// Budget tiers for AI planner
enum BudgetTier {
  budget,
  moderate,
  luxury;
}

/// Guide verification status
enum VerificationStatus {
  pending,
  approved,
  rejected,
  moreInfoRequired;

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}
