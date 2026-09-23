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

  testWidgets('Properties navigation opens properties page',
      (WidgetTester tester) async {
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

  testWidgets('Property search filters results by location',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GiftedPropertyApp());

    await tester.tap(find.text('Properties').first);
    await tester.pumpAndSettle();

    expect(find.text('5 Bedroom Luxury Home'), findsOneWidget);
    expect(find.text('4 Bedroom Terrace Duplex'), findsOneWidget);
    expect(find.text('Off Plan Villa'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Guzape',
    );
    await tester.pump();

    expect(find.text('4 Bedroom Terrace Duplex'), findsOneWidget);
    expect(find.text('5 Bedroom Luxury Home'), findsNothing);
    expect(find.text('Off Plan Villa'), findsNothing);
  });
}
