import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/config/sample_data_config.dart';
import 'package:gifted_property/data/properties.dart' as legacy;
import 'package:gifted_property/data/sample_abuja_properties.dart';

void main() {
  test('sample Abuja listings are clearly labelled and never verified', () {
    expect(sampleAbujaProperties, isNotEmpty);

    for (final property in sampleAbujaProperties) {
      expect(property.title, startsWith('SAMPLE ONLY —'));
      expect(property.description, contains('DEMO LISTING ONLY'));
      expect(
        property.features,
        contains('Fictional price — not a market quote'),
      );
      expect(property.status, 'Sample — not for sale');
      expect(property.isSample, isTrue);
      expect(property.hasCoordinates, isTrue);
      expect(property.hasVerifiedLocation, isFalse);
      expect(property.locationVerificationStatus, 'approximate');
      expect(property.imageUrls, isEmpty);
      expect(property.displayImageUrls, isEmpty);
    }
  });

  test(
    'debug sample flag is honored but profile/release builds disable it',
    () {
      expect(
        sampleDataEnabled,
        shouldEnableSampleData(
          isDebugMode: true,
          requested: sampleDataRequested,
        ),
      );
      expect(
        shouldEnableSampleData(isDebugMode: false, requested: true),
        isFalse,
      );
    },
  );

  test('legacy unguarded fixture list remains empty', () {
    // ignore: deprecated_member_use
    expect(legacy.properties, isEmpty);
  });

  test('Supabase is skipped only for an explicitly requested debug demo', () {
    expect(
      shouldInitializeSupabase(isDebugMode: true, sampleDataRequested: true),
      isFalse,
    );
    expect(
      shouldInitializeSupabase(isDebugMode: true, sampleDataRequested: false),
      isTrue,
    );
    expect(
      shouldInitializeSupabase(isDebugMode: false, sampleDataRequested: true),
      isTrue,
    );
  });
}
