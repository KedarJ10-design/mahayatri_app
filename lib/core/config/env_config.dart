import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration using flutter_dotenv.
///
/// Loads values from .env file at runtime.
/// Create a `.env` file in the project root with:
/// ```
/// SUPABASE_URL=https://your-project.supabase.co
/// SUPABASE_ANON_KEY=your-anon-key
/// ```
abstract final class EnvConfig {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Call this in main() before using any config values.
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}
