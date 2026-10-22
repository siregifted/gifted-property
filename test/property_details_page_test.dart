import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/models/property.dart';
import 'package:gifted_property/pages/property_details_page.dart';
import 'package:gifted_property/widgets/property_location_map.dart';

const _demoProperty = Property(
  title: 'SAMPLE ONLY — Demo home',
  location: 'Maitama, Abuja (approximate area pin)',
  price: 1,
  bedrooms: 2,
  bathrooms: 1,
  propertyType: 'Apartment',
  description: 'DEMO LISTING ONLY.',
  imageUrls: [],
  features: [],
  status: 'Sample — not for sale',
  isSample: true,
  locationVerificationStatus: 'approximate',
);

void main() {
  testWidgets('demo details clearly warn and disable buyer lead actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PropertyDetailsPage(property: _demoProperty)),
    );
    await tester.pump();

    expect(
      find.text(
        'DEMO ONLY — fictional listing and price; approximate area pin. Not for sale; do not use to arrange a viewing.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Demo listing only. Enquiries and inspection requests are disabled.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Schedule Inspection'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Contact Agent'),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero ID listing does not open disabled lead forms', (
    WidgetTester tester,
  ) async {
    const property = Property(
      id: 0,
      title: 'Malformed catalogue row',
      location: 'Abuja',
      price: 1,
      bedrooms: 1,
      bathrooms: 1,
      propertyType: 'Apartment',
      description: '',
      imageUrls: [],
      features: [],
      status: 'Available',
    );

    await tester.pumpWidget(
      const MaterialApp(home: PropertyDetailsPage(property: property)),
    );
    await tester.pump();

    expect(
      find.text('This listing is not ready to accept requests yet.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Schedule Inspection'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Contact Agent'),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('unverified coordinates do not render a map or directions', (
    WidgetTester tester,
  ) async {
    const property = Property(
      title: 'Unverified listing',
      location: 'Area available on request',
      price: 0,
      bedrooms: 0,
      bathrooms: 0,
      propertyType: 'Property',
      description: '',
      imageUrls: [],
      features: [],
      status: 'Available',
      latitude: 9.0,
      longitude: 7.0,
      locationVerificationStatus: 'unverified',
    );

    await tester.pumpWidget(
      const MaterialApp(home: PropertyLocationMap(property: property)),
    );
    await tester.pump();

    expect(
      find.textContaining('Map pins and directions are withheld'),
      findsOneWidget,
    );
    expect(find.byType(OutlinedButton), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
