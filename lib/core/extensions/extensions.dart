import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extension methods on BuildContext for convenient access to theme data.
extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Show a snackbar with the given message
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}

/// Extension methods on String for common transformations.
extension StringExtensions on String {
  /// Capitalize the first letter
  String get capitalized =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate with ellipsis
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';

  /// Check if string is a valid email
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Check if string is a valid Indian phone number
  bool get isValidPhone =>
      RegExp(r'^[6-9]\d{9}$').hasMatch(replaceAll(RegExp(r'[\s\-\+]'), ''));
}

/// Extension methods on DateTime for formatting.
extension DateTimeExtensions on DateTime {
  /// Format as "15 May 2026"
  String get formatted => DateFormat('d MMM yyyy').format(this);

  /// Format as "15 May"
  String get shortFormatted => DateFormat('d MMM').format(this);

  /// Format as "3:30 PM"
  String get timeFormatted => DateFormat('h:mm a').format(this);

  /// Format as "May 15, 2026 at 3:30 PM"
  String get fullFormatted => DateFormat('MMM d, yyyy \'at\' h:mm a').format(this);

  /// Check if same day as another date
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

/// Extension methods on num for currency formatting.
extension NumExtensions on num {
  /// Format as Indian currency: ₹1,23,456
  String get toCurrency => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(this);

  /// Format as compact: ₹1.2L, ₹45K
  String get toCurrencyCompact => NumberFormat.compactCurrency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 1,
      ).format(this);
}
