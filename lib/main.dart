import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/app_logger.dart';

/// Application entry point.
///
/// Initialization order:
/// 1. Flutter engine binding
/// 2. System UI chrome styling
/// 3. Environment config (.env)
/// 4. Hive local storage
/// 5. Supabase client
/// 6. Launch app with Riverpod scope
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar for immersive design
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Load environment variables
  await EnvConfig.load();
  log.i('Environment loaded');

  // Initialize Hive for local caching
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.hiveCacheBox);
  await Hive.openBox(AppConstants.hiveUserBox);
  log.i('Hive initialized');

  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
  log.i('Supabase initialized');

  // Launch app
  runApp(
    const ProviderScope(
      child: MahayatriApp(),
    ),
  );
}
