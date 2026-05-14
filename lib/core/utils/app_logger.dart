import 'package:logger/logger.dart';

/// Global logger instance.
///
/// Usage:
/// ```dart
/// import 'package:mahayatri_app/core/utils/logger.dart';
///
/// log.d('Debug message');
/// log.i('Info message');
/// log.w('Warning message');
/// log.e('Error message', error: exception, stackTrace: stackTrace);
/// ```
final log = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// Production logger with minimal output
final logProd = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 120,
    colors: false,
    printEmojis: false,
  ),
  level: Level.warning,
);
