import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/main.dart';

void main() {
  testWidgets('Gifted Property home page loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GiftedPropertyApp());

    expect(find.text('GIFTED PROPERTY'), findsOneWidget);
    expect(find.text('Featured Properties'), findsOneWidget);
    expect(find.text('FIND A PROPERTY\nWORTH INVESTING IN.'), findsOneWidget);
    expect(find.text('Properties'), findsOneWidget);
  });

  testWidgets('Properties navigation opens properties page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GiftedPropertyApp());
    await tester.tap(find.text('Properties').first);
    await tester.pumpAndSettle();

    expect(find.text('Our Properties'), findsOneWidget);
    expect(
      find.text(
        'Explore premium properties available through Gifted Property.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Property search filters results by location', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GiftedPropertyApp());
    await tester.tap(find.text('Properties').first);
    await tester.pumpAndSettle();

    expect(find.text('5 Bedroom Luxury Home'), findsOneWidget);
    expect(find.text('4 Bedroom Terrace Duplex'), findsOneWidget);
    expect(find.text('Off Plan Villa'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Guzape');
    await tester.pump();

    expect(find.text('4 Bedroom Terrace Duplex'), findsOneWidget);
    expect(find.text('5 Bedroom Luxury Home'), findsNothing);
    expect(find.text('Off Plan Villa'), findsNothing);
  });

  testWidgets('Home search opens filtered results on a phone', (
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
    expect(find.text('4 Bedroom Terrace Duplex'), findsOneWidget);
    expect(find.text('5 Bedroom Luxury Home'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mobile property details open a validated enquiry form', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GiftedPropertyApp());
    await tester.enterText(find.byType(TextField).first, 'Katampe');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 Bedroom Luxury Home'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Contact Agent'));
    await tester.tap(find.text('Contact Agent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit Enquiry'));
    await tester.pumpAndSettle();

    expect(find.text('Make an Enquiry'), findsOneWidget);
    expect(find.text('Please enter your full name.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inspection request requires a date and time before submission', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GiftedPropertyApp());
    await tester.enterText(find.byType(TextField).first, 'Katampe');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 Bedroom Luxury Home'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Schedule Inspection'));
    await tester.tap(find.text('Schedule Inspection'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test Buyer');
    await tester.enterText(fields.at(1), '+2348012345678');
    await tester.enterText(fields.at(2), 'buyer@example.com');
    await tester.enterText(fields.at(3), 'I would like to view the property.');
    await tester.ensureVisible(find.text('Request Inspection'));
    await tester.tap(find.text('Request Inspection'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please select an inspection date and preferred time.'),
      findsOneWidget,
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

    await tester.pumpWidget(const GiftedPropertyApp());
    expect(find.text('GIFTED PROPERTY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
