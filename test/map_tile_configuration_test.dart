import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/config/map_tiles_config.dart';
import 'package:gifted_property/models/property.dart';
import 'package:gifted_property/widgets/navigation_route_map.dart';
import 'package:gifted_property/widgets/property_location_map.dart';
import 'package:latlong2/latlong.dart';

const _verifiedProperty = Property(
  id: 42,
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

void _expectCompliantLayer(WidgetTester tester) {
  final tileLayer = tester.widget<TileLayer>(find.byType(TileLayer));
  expect(tileLayer.urlTemplate, MapTilesConfig.urlTemplate);
  expect(
    tileLayer.tileProvider.headers['User-Agent'],
    'flutter_map (${MapTilesConfig.userAgentPackageName})',
  );
  expect(tileLayer.additionalOptions, MapTilesConfig.additionalOptions);

  final attributionWidget = tester.widget<RichAttributionWidget>(
    find.byType(RichAttributionWidget),
  );
  final tileAttribution = attributionWidget.attributions
      .whereType<TextSourceAttribution>()
      .firstWhere((source) => source.text.contains('OpenStreetMap'));
  expect(tileAttribution.text, MapTilesConfig.attributionText);
  expect(tileAttribution.prependCopyright, isFalse);
  expect(tileAttribution.onTap, isNotNull);
}

void main() {
  test(
    'default map configuration uses the official HTTPS OSM tile endpoint',
    () {
      expect(
        MapTilesConfig.urlTemplate,
        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      );
      expect(
        MapTilesConfig.userAgentPackageName,
        'com.siregifted.giftedproperty',
      );
      expect(MapTilesConfig.attributionText, '© OpenStreetMap contributors');
      expect(
        MapTilesConfig.attributionUrl,
        'https://www.openstreetmap.org/copyright',
      );
    },
  );

  test('native tile identity matches the Android application ID', () {
    final androidGradle = File('android/app/build.gradle.kts')
        .readAsStringSync();
    expect(
      androidGradle,
      contains('applicationId = "${MapTilesConfig.userAgentPackageName}"'),
    );
  });

  test('web document permits a privacy-preserving OSM Referer', () {
    final webIndex = File('web/index.html').readAsStringSync();
    expect(
      webIndex,
      contains(
        '<meta name="referrer" content="strict-origin-when-cross-origin">',
      ),
    );
  });

  testWidgets('property detail map uses shared tile policy configuration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SingleChildScrollView(
          child: PropertyLocationMap(property: _verifiedProperty),
        ),
      ),
    );
    await tester.pump();

    _expectCompliantLayer(tester);
    expect(find.text('Preview route in Gifted Property'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('route preview map uses shared tile policy configuration', (
    WidgetTester tester,
  ) async {
    final controller = MapController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: NavigationRouteMap(
              controller: controller,
              destination: const LatLng(9.08, 7.49),
              currentLocation: null,
              route: null,
              approximateDestination: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    _expectCompliantLayer(tester);
    expect(tester.takeException(), isNull);
  });
}
