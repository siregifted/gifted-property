import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/models/navigation_route.dart';
import 'package:gifted_property/models/property.dart';
import 'package:gifted_property/pages/property_navigation_page.dart';
import 'package:gifted_property/services/foreground_location_source.dart';
import 'package:latlong2/latlong.dart';

const _sampleProperty = Property(
  id: 0,
  title: 'SAMPLE ONLY — fictional listing',
  location: 'Abuja (approximate area pin)',
  price: 1,
  bedrooms: 2,
  bathrooms: 1,
  propertyType: 'Apartment',
  description: 'Fictional sample only.',
  imageUrls: [],
  features: [],
  status: 'Sample — not for sale',
  isSample: true,
  latitude: 9.08,
  longitude: 7.49,
  locationVerificationStatus: 'approximate',
);

const _approximateProperty = Property(
  id: 12,
  title: 'Reviewed property',
  location: 'Maitama, Abuja (approximate area)',
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
  locationVerificationStatus: 'approximate',
);

const _verifiedProperty = Property(
  id: 13,
  title: 'Verified property',
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

class _FakeLocationSource implements ForegroundLocationSource {
  _FakeLocationSource({this.failure});

  final Object? failure;
  int requests = 0;

  @override
  Future<LatLng> requestCurrentLocation() async {
    requests++;
    if (failure != null) throw failure!;
    return const LatLng(9.07, 7.48);
  }

  @override
  Stream<LatLng> watchCurrentLocation() => const Stream.empty();
}

NavigationRoute _testRoute() => NavigationRoute(
  points: const [LatLng(9.07, 7.48), LatLng(9.08, 7.49)],
  distanceMeters: 1530,
  durationSeconds: 512,
  steps: const [
    NavigationStep(
      instruction: 'Head north',
      distanceMeters: 250,
      maneuverPoint: LatLng(9.08, 7.49),
    ),
  ],
);

void main() {
  testWidgets(
    'demo listings cannot start navigation or request device location',
    (WidgetTester tester) async {
      final locationSource = _FakeLocationSource();
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyNavigationPage(
            property: _sampleProperty,
            locationSource: locationSource,
          ),
        ),
      );

      expect(
        find.text('Navigation is disabled for fictional demo listings.'),
        findsOneWidget,
      );
      expect(find.text('Start route'), findsNothing);
      expect(locationSource.requests, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'approximate destination requires acknowledgement before requesting route',
    (WidgetTester tester) async {
      final locationSource = _FakeLocationSource();
      LatLng? requestedOrigin;
      LatLng? requestedDestination;
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyNavigationPage(
            property: _approximateProperty,
            locationSource: locationSource,
            routeLoader: (origin, destination) async {
              requestedOrigin = origin;
              requestedDestination = destination;
              return _testRoute();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('I understand this route ends at an approximate area pin.'),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
        isNull,
      );

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start route'));
      await tester.pumpAndSettle();

      expect(locationSource.requests, 1);
      expect(requestedOrigin, const LatLng(9.07, 7.48));
      expect(requestedDestination, const LatLng(9.08, 7.49));
      expect(find.textContaining('1.5 km'), findsOneWidget);
      expect(find.text('Continue in Maps'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'foreground location denial offers a recovery option and does not crash',
    (WidgetTester tester) async {
      final locationSource = _FakeLocationSource(
        failure: const ForegroundLocationException(
          'Location permission was not granted. You can enable it and try again.',
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyNavigationPage(
            property: _verifiedProperty,
            locationSource: locationSource,
            routeLoader: (origin, destination) async => _testRoute(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start route'));
      await tester.pumpAndSettle();

      expect(locationSource.requests, 1);
      expect(
        find.text(
          'Location permission was not granted. You can enable it and try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Try Maps instead'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
