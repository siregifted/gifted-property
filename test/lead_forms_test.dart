import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/models/enquiry.dart';
import 'package:gifted_property/models/property.dart';
import 'package:gifted_property/pages/enquiry_page.dart';
import 'package:gifted_property/pages/inspection_page.dart';

const _publishedProperty = Property(
  id: 17,
  title: 'Published test listing',
  location: 'Maitama, Abuja',
  price: 1,
  bedrooms: 2,
  bathrooms: 1,
  propertyType: 'Apartment',
  description: 'Test-only widget fixture.',
  imageUrls: [],
  features: [],
  status: 'Available',
);

Widget _routeTo(Widget page) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (context) => page)),
            child: const Text('Open form'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _fillEnquiry(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Ada Lovelace');
  await tester.enterText(fields.at(1), '+234 (801) 234-5678');
  await tester.enterText(fields.at(2), 'ada@example.com');
  await tester.enterText(fields.at(3), 'Please send more details.');
  await tester.ensureVisible(find.text('Submit Enquiry'));
}

void main() {
  testWidgets('valid enquiry submits once and shows success feedback', (
    WidgetTester tester,
  ) async {
    Enquiry? submitted;
    await tester.pumpWidget(
      _routeTo(
        EnquiryPage(
          property: _publishedProperty,
          onSubmit: (enquiry) async => submitted = enquiry,
        ),
      ),
    );
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    await _fillEnquiry(tester);
    await tester.tap(find.text('Submit Enquiry'));
    await tester.pumpAndSettle();

    expect(submitted?.propertyId, 17);
    expect(submitted?.name, 'Ada Lovelace');
    expect(find.text('Your enquiry has been submitted.'), findsOneWidget);
  });

  testWidgets(
    'enquiry network failure keeps the form and shows retry guidance',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _routeTo(
          EnquiryPage(
            property: _publishedProperty,
            onSubmit: (enquiry) async => throw StateError('offline'),
          ),
        ),
      );
      await tester.tap(find.text('Open form'));
      await tester.pumpAndSettle();
      await _fillEnquiry(tester);
      await tester.tap(find.text('Submit Enquiry'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'We could not send your enquiry. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Submit Enquiry'), findsOneWidget);
    },
  );

  testWidgets('inspection form requires a date and time before submission', (
    WidgetTester tester,
  ) async {
    var submitted = false;
    await tester.pumpWidget(
      _routeTo(
        InspectionPage(
          property: _publishedProperty,
          onSubmit: (inspection) async => submitted = true,
        ),
      ),
    );
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ada Lovelace');
    await tester.enterText(fields.at(1), '+234 (801) 234-5678');
    await tester.enterText(fields.at(2), 'ada@example.com');
    await tester.enterText(fields.at(3), 'Please arrange a viewing.');
    await tester.ensureVisible(find.text('Request Inspection'));
    await tester.tap(find.text('Request Inspection'));
    await tester.pumpAndSettle();

    expect(submitted, isFalse);
    expect(
      find.text(
        'Select a date from today through one year ahead (Abuja time).',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'sample inspection requests are disabled even if opened directly',
    (WidgetTester tester) async {
      const sample = Property(
        title: 'SAMPLE ONLY — Test listing',
        location: 'Abuja (demo area)',
        price: 0,
        bedrooms: 1,
        bathrooms: 1,
        propertyType: 'Apartment',
        description: 'DEMO LISTING ONLY.',
        imageUrls: [],
        features: [],
        status: 'Sample — not for sale',
        isSample: true,
      );

      await tester.pumpWidget(
        MaterialApp(home: InspectionPage(property: sample)),
      );
      await tester.pump();

      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Request Inspection'),
            )
            .onPressed,
        isNull,
      );
      expect(
        find.text('Demo listings cannot schedule inspections.'),
        findsOneWidget,
      );
    },
  );
}
