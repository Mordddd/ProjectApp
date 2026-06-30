import 'package:supabase_flutter/supabase_flutter.dart';

/// Build-time Supabase configuration.
///
/// Pass values with --dart-define so credentials never need to live in source.
class SupabaseConfig {
  SupabaseConfig._();

  static const requiredForBuild = bool.fromEnvironment('SUPABASE_REQUIRED');
  static const environment = String.fromEnvironment(
    'SUPABASE_ENV',
    defaultValue: 'local',
  );
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const _legacyAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static String get key =>
      publishableKey.isNotEmpty ? publishableKey : _legacyAnonKey;

  static bool get isConfigured => url.isNotEmpty && key.isNotEmpty;

  static String get projectHost {
    final uri = Uri.tryParse(url);
    return uri?.host.isNotEmpty == true ? uri!.host : 'belum dikonfigurasi';
  }

  static SupabaseClient get client {
    if (!isConfigured) {
      throw StateError('Supabase is not configured for this build.');
    }
    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    if (!isConfigured) {
      if (requiredForBuild) {
        throw StateError(
          'Supabase wajib aktif, tetapi SUPABASE_URL atau '
          'SUPABASE_PUBLISHABLE_KEY belum tersedia.',
        );
      }
      return;
    }

    if (key.startsWith('sb_secret_')) {
      throw StateError(
        'Secret key tidak boleh ditanam di aplikasi klien. '
        'Gunakan publishable key Supabase.',
      );
    }

    await Supabase.initialize(url: url, publishableKey: key);
  }
}
