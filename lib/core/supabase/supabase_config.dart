import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty || url.contains('placeholder')) {
      debugPrint(
        '⚠️ [SupabaseConfig] Variables SUPABASE_URL ou SUPABASE_ANON_KEY manquantes dans .env.',
      );
    }

    try {
      await Supabase.initialize(
        url: url.isNotEmpty ? url : 'https://placeholder.supabase.co',
        publishableKey: anonKey.isNotEmpty ? anonKey : 'placeholder-anon-key',
        authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
      );
      debugPrint('✅ [SupabaseConfig] Supabase initialisé avec succès.');
    } catch (e) {
      debugPrint('❌ [SupabaseConfig] Erreur initialisation Supabase : $e');
    }
  }
}
