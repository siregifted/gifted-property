import 'dart:convert';

class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured =>
      isValidConfiguration(url: url, key: publishableKey);

  static bool isValidConfiguration({required String url, required String key}) {
    if (url != url.trim()) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        isSafePublishableKey(key);
  }

  static bool isSafePublishableKey(String key) {
    if (key != key.trim() || key.isEmpty || key.startsWith('sb_secret_')) {
      return false;
    }
    if (key.startsWith('sb_publishable_')) {
      return key.length > 'sb_publishable_'.length;
    }

    final segments = key.split('.');
    if (segments.length != 3) return false;
    try {
      final decoded = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(segments[1]))),
      );
      return decoded is Map && decoded['role'] == 'anon';
    } on FormatException {
      return false;
    }
  }
}
