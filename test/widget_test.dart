import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/main.dart';
import 'package:gifted_property/models/property.dart';
import 'package:gifted_property/widgets/property_card.dart';

void main() {
  testWidgets('Gifted Property home page renders the buyer landing page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GiftedPropertyApp());
    await tester.pump();

    expect(find.text('GIFTED PROPERTY'), findsOneWidget);
    expect(find.text('Featured Properties'), findsOneWidget);
    expect(find.text('FIND A PROPERTY\nWORTH INVESTING IN.'), findsOneWidget);
    expect(find.text('Properties'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Properties navigation opens the catalogue and search field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GiftedPropertyApp());
    await tester.tap(find.text('Properties').first);
    await tester.pumpAndSettle();

    expect(find.text('Our Properties'), findsOneWidget);
    expect(
      find.text(
        'Explore published properties available through Gifted Property.',
      ),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Catalogue shows a recoverable message when loading fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GiftedPropertyApp());
    await tester.tap(find.text('Properties').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Properties could not be loaded. Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home search opens the catalogue with the query on mobile', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GiftedPropertyApp());
    await tester.enterText(find.byType(TextField).first, 'Guzape');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.text('Our Properties'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      'Guzape',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Property card fits a narrow 320-pixel phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const property = Property(
      title: 'Three-bedroom apartment in Katampe Extension',
      location: 'Katampe Extension, Abuja',
      price: 18000000,
      bedrooms: 3,
      bathrooms: 2,
      propertyType: 'Apartment',
      description: 'A test property.',
      imageUrls: [],
      features: [],
      status: 'Available',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: PropertyCard(property: property),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(property.title), findsOneWidget);
    expect(find.text(property.location), findsOneWidget);
    expect(find.text('3 Beds'), findsOneWidget);
    expect(find.text('2 Baths'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home layout fits a narrow 320-pixel phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GiftedPropertyApp());
    await tester.pump();

    expect(find.text('GIFTED PROPERTY'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Search location or property',
      ),
      findsOneWidget,
    );
    expect(find.text('Katampe Extension'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
