import 'package:supabase_flutter/supabase_flutter.dart';

/// Build-time Supabase configuration.
///
/// Pass values with --dart-define so credentials never need to live in source.
class SupabaseConfig {
  SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const _legacyAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static String get key =>
      publishableKey.isNotEmpty ? publishableKey : _legacyAnonKey;

  static bool get isConfigured => url.isNotEmpty && key.isNotEmpty;

  static SupabaseClient get client {
    if (!isConfigured) {
      throw StateError('Supabase is not configured for this build.');
    }
    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    if (!isConfigured) return;
    await Supabase.initialize(url: url, publishableKey: key);
  }
}
