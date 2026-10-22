import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/main.dart';
import 'package:gifted_property/models/property.dart';

Future<List<Property>> _emptyProperties() async => const [];

Widget _testApp({
  Future<List<Property>> Function()? featuredLoader,
  Future<List<Property>> Function()? propertyLoader,
}) {
  return GiftedPropertyApp(
    featuredPropertyLoader: featuredLoader ?? _emptyProperties,
    propertyLoader: propertyLoader ?? _emptyProperties,
  );
}

void main() {
  testWidgets('Gifted Property home page renders the buyer landing page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
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
    await tester.pumpWidget(_testApp());
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
    expect(
      find.text(
        'There are no published properties yet. Please check back soon.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Catalogue shows a recoverable message when loading fails', (
    WidgetTester tester,
  ) async {
    var attempts = 0;
    Future<List<Property>> loadProperties() async {
      attempts++;
      if (attempts == 1) throw StateError('offline');
      return const [];
    }

    await tester.pumpWidget(_testApp(propertyLoader: loadProperties));
    await tester.tap(find.text('Properties').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Properties could not be loaded. Check your connection and try again.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'There are no published properties yet. Please check back soon.',
      ),
      findsOneWidget,
    );
    expect(attempts, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home featured section can retry after a load failure', (
    WidgetTester tester,
  ) async {
    var attempts = 0;
    Future<List<Property>> loadFeatured() async {
      attempts++;
      if (attempts == 1) throw StateError('offline');
      return const [];
    }

    await tester.pumpWidget(_testApp(featuredLoader: loadFeatured));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Featured properties could not be loaded. Check your connection and try again.',
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(
      find.text('No featured properties are published yet.'),
      findsOneWidget,
    );
    expect(attempts, 2);
  });

  testWidgets('Home search opens the catalogue with the query on mobile', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
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

  testWidgets('Home layout fits a narrow 320-pixel phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pump();

    expect(find.text('GIFTED PROPERTY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Startup configuration failure has a recoverable message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const GiftedPropertyApp(startupError: 'configuration unavailable'),
    );

    expect(
      find.textContaining('could not start because its listing service is'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
