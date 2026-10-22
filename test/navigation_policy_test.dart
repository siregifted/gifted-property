import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/models/property.dart';
import 'package:gifted_property/validation/navigation_policy.dart';

Property _property({
  bool isSample = false,
  double? latitude = 9.08,
  double? longitude = 7.49,
  String verification = 'verified',
}) => Property(
  id: 5,
  title: 'Residential listing',
  location: 'Maitama, Abuja',
  price: 100,
  bedrooms: 2,
  bathrooms: 2,
  propertyType: 'Apartment',
  description: '',
  imageUrls: const [],
  features: const [],
  status: 'Available',
  isSample: isSample,
  latitude: latitude,
  longitude: longitude,
  locationVerificationStatus: verification,
);

void main() {
  test('verified real listing can preview a route', () {
    final property = _property();
    expect(canPreviewPropertyRoute(property), isTrue);
    expect(requiresApproximateRouteAcknowledgement(property), isFalse);
  });

  test('approximate real listing requires explicit acknowledgement', () {
    final property = _property(verification: 'approximate');
    expect(canPreviewPropertyRoute(property), isTrue);
    expect(requiresApproximateRouteAcknowledgement(property), isTrue);
  });

  test('demo, unverified, missing and out-of-range locations cannot route', () {
    expect(canPreviewPropertyRoute(_property(isSample: true)), isFalse);
    expect(
      canPreviewPropertyRoute(_property(verification: 'unverified')),
      isFalse,
    );
    expect(canPreviewPropertyRoute(_property(latitude: null)), isFalse);
    expect(canPreviewPropertyRoute(_property(latitude: 120)), isFalse);
  });
}
