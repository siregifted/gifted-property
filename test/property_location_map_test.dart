import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/models/property.dart';
import 'package:gifted_property/widgets/property_location_map.dart';

const _sample = Property(
  id: 0,
  title: 'SAMPLE ONLY — fictional home',
  location: 'Abuja (approximate area pin)',
  price: 1,
  bedrooms: 2,
  bathrooms: 1,
  propertyType: 'Apartment',
  description: '',
  imageUrls: [],
  features: [],
  status: 'Sample — not for sale',
  isSample: true,
  latitude: 9.08,
  longitude: 7.49,
  locationVerificationStatus: 'approximate',
);

const _verified = Property(
  id: 12,
  title: 'Verified home',
  location: 'Maitama, Abuja',
  price: 100,
  bedrooms: 2,
  bathrooms: 2,
  propertyType: 'Apartment',
  description: '',
  imageUrls: [],
  features: [],
  status: 'Available',
  latitude: 9.08,
  longitude: 7.49,
  locationVerificationStatus: 'verified',
);

void main() {
  testWidgets('sample pin has no navigation or external Maps action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SingleChildScrollView(
          child: PropertyLocationMap(property: _sample),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Demo sample — navigation is disabled.'), findsOneWidget);
    expect(find.text('Preview route in Gifted Property'), findsNothing);
    expect(find.text('Open approximate area in Maps'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verified pin exposes in-app route preview', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SingleChildScrollView(
          child: PropertyLocationMap(property: _verified),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Preview route in Gifted Property'), findsOneWidget);
    expect(find.text('Open directions in Maps'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
