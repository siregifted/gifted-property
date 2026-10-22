import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/validation/lead_validators.dart';

void main() {
  test('lead validators enforce the database field limits', () {
    expect(validateLeadName(' A '), isNotNull);
    expect(validateLeadName('  Ada Lovelace  '), isNull);
    expect(validateLeadName('x' * 121), isNotNull);
    expect(validateLeadPhone('+234 (801) 234-5678'), isNull);
    expect(validateLeadPhone('call me 1234567'), isNotNull);
    expect(validateLeadEmail('ada@example.com'), isNull);
    expect(validateLeadEmail('not-an-email'), isNotNull);
    expect(validateLeadMessage('Please call me.'), isNull);
    expect(validateLeadMessage(' '), isNotNull);
    expect(validateLeadMessage('m' * 4001), isNotNull);
  });

  test('inspection dates use Abuja calendar day and a one-year window', () {
    final lateUtc = DateTime.utc(2026, 10, 22, 23, 30);
    final todayInAbuja = DateTime(2026, 10, 23);

    expect(lagosCalendarDate(lateUtc), todayInAbuja);
    expect(isAllowedInspectionDate(DateTime(2026, 10, 22), lateUtc), isFalse);
    expect(isAllowedInspectionDate(todayInAbuja, lateUtc), isTrue);
    expect(isAllowedInspectionDate(DateTime(2027, 10, 23), lateUtc), isTrue);
    expect(isAllowedInspectionDate(DateTime(2027, 10, 24), lateUtc), isFalse);
  });

  test('leap-year end date clamps to the last day of February', () {
    expect(
      addOneCalendarYearClamped(DateTime(2024, 2, 29)),
      DateTime(2025, 2, 28),
    );
  });

  test(
    'inspection date and preferred time serialize as local calendar values',
    () {
      expect(formatInspectionDate(DateTime(2026, 10, 9)), '2026-10-09');
      expect(formatInspectionTime(0, 5), '00:05');
      expect(formatInspectionTime(17, 30), '17:30');
    },
  );
}
