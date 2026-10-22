import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/data/sample_abuja_properties.dart';

void main() {
  test('sample Abuja listings are clearly labelled and never verified', () {
    expect(sampleAbujaProperties, isNotEmpty);

    for (final property in sampleAbujaProperties) {
      expect(property.title, startsWith('SAMPLE ONLY —'));
      expect(property.description, contains('DEMO LISTING ONLY'));
      expect(property.status, 'Sample — not for sale');
      expect(property.hasCoordinates, isTrue);
      expect(property.hasVerifiedLocation, isFalse);
      expect(property.locationVerificationStatus, 'approximate');
      expect(property.imageUrls, isEmpty);
    }
  });
}
