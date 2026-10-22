import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/config/supabase_config.dart';

String _jwtForRole(String role) {
  String encode(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');
  final header = encode('{"alg":"none","typ":"JWT"}');
  final payload = encode('{"role":"$role"}');
  return '$header.$payload.signature';
}

void main() {
  test('requires an explicit HTTPS endpoint and client-safe key', () {
    expect(
      SupabaseConfig.isValidConfiguration(
        url: 'https://staging.example.supabase.co',
        key: 'sb_publishable_test-value',
      ),
      isTrue,
    );
    expect(
      SupabaseConfig.isValidConfiguration(
        url: '',
        key: 'sb_publishable_test-value',
      ),
      isFalse,
    );
    expect(
      SupabaseConfig.isValidConfiguration(
        url: 'http://staging.example.supabase.co',
        key: 'sb_publishable_test-value',
      ),
      isFalse,
    );
  });

  test(
    'accepts anonymous JWT keys but rejects secrets and service-role keys',
    () {
      expect(SupabaseConfig.isSafePublishableKey(_jwtForRole('anon')), isTrue);
      expect(
        SupabaseConfig.isSafePublishableKey('sb_publishable_test-value'),
        isTrue,
      );
      expect(
        SupabaseConfig.isSafePublishableKey('sb_secret_test-value'),
        isFalse,
      );
      expect(
        SupabaseConfig.isSafePublishableKey(_jwtForRole('service_role')),
        isFalse,
      );
      expect(SupabaseConfig.isSafePublishableKey('not-a-key'), isFalse);
    },
  );
}
