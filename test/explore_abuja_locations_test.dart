import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/main.dart';
import 'package:gifted_property/models/property.dart';
import 'package:gifted_property/widgets/explore_abuja_locations.dart';

Future<List<Property>> _emptyProperties() async => const [];

Widget _locationDiscoveryApp({required ValueChanged<String> onSelected}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ExploreAbujaLocations(onLocationSelected: onSelected),
      ),
    ),
  );
}

Finder _textFieldWithHint(String hint) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.hintText == hint,
);

void main() {
  testWidgets('location search filters districts and emits the selection', (
    WidgetTester tester,
  ) async {
    final selectedLocations = <String>[];
    await tester.pumpWidget(
      _locationDiscoveryApp(onSelected: selectedLocations.add),
    );

    await tester.enterText(
      _textFieldWithHint('Search Abuja districts'),
      'Gwarinpa',
    );
    await tester.pump();

    expect(find.text('Gwarinpa'), findsNWidgets(2));
    expect(find.text('Maitama'), findsNothing);
    await tester.tap(find.text('Gwarinpa').last);

    expect(selectedLocations, ['Gwarinpa']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('View all locations shows groups and filters the full list', (
    WidgetTester tester,
  ) async {
    final selectedLocations = <String>[];
    await tester.pumpWidget(
      _locationDiscoveryApp(onSelected: selectedLocations.add),
    );

    await tester.tap(find.text('View all locations'));
    await tester.pumpAndSettle();

    expect(find.text('All Abuja locations'), findsOneWidget);
    expect(find.text('PREMIUM LOCATIONS'), findsOneWidget);
    expect(find.text('RESIDENTIAL AND DEVELOPING LOCATIONS'), findsOneWidget);

    await tester.enterText(_textFieldWithHint('Search all districts'), 'Kubwa');
    await tester.pump();

    expect(find.text('Kubwa'), findsNWidgets(2));
    expect(find.text('PREMIUM LOCATIONS'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ListView).last,
        matching: find.text('Maitama'),
      ),
      findsNothing,
    );
    await tester.tap(find.text('Kubwa').last);
    await tester.pumpAndSettle();

    expect(selectedLocations, ['Kubwa']);
    expect(find.text('All Abuja locations'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('homepage location selection opens catalogue with that query', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GiftedPropertyApp(
        featuredPropertyLoader: _emptyProperties,
        propertyLoader: _emptyProperties,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('View all locations'));
    await tester.tap(find.text('View all locations'));
    await tester.pumpAndSettle();
    await tester.enterText(
      _textFieldWithHint('Search all districts'),
      'Gwarinpa',
    );
    await tester.pump();
    await tester.tap(find.text('Gwarinpa').last);
    await tester.pumpAndSettle();

    expect(find.text('Our Properties'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      'Gwarinpa',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('location discovery fits a narrow 320-pixel phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GiftedPropertyApp(
        featuredPropertyLoader: _emptyProperties,
        propertyLoader: _emptyProperties,
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Katampe Extension'));

    expect(find.text('Explore Abuja Locations'), findsOneWidget);
    expect(find.text('Katampe Extension'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
