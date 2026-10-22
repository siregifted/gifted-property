String? validateLeadName(String? value) {
  final name = value?.trim() ?? '';
  if (name.length < 2) return 'Please enter your full name.';
  if (name.length > 120) return 'Please keep your name under 120 characters.';
  return null;
}

String? validateLeadPhone(String? value) {
  final phone = value?.trim() ?? '';
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (phone.length < 7 ||
      phone.length > 32 ||
      digits.length < 7 ||
      digits.length > 20 ||
      !RegExp(r'^[0-9+\s().-]+$').hasMatch(phone)) {
    return 'Please enter a valid phone number.';
  }
  return null;
}

String? validateLeadEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.length > 254 ||
      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Please enter a valid email.';
  }
  return null;
}

String? validateLeadMessage(String? value) {
  final message = value?.trim() ?? '';
  if (message.isEmpty) return 'Please enter your message.';
  if (message.length > 4000) {
    return 'Please keep your message under 4000 characters.';
  }
  return null;
}

/// Returns the current calendar date in Abuja/Lagos (WAT, UTC+1).
/// `utcNow` must be a UTC timestamp; Nigeria does not observe daylight saving.
DateTime lagosCalendarDate(DateTime utcNow) {
  final lagos = utcNow.toUtc().add(const Duration(hours: 1));
  return DateTime(lagos.year, lagos.month, lagos.day);
}

DateTime addOneCalendarYearClamped(DateTime date) {
  final targetYear = date.year + 1;
  final lastDayOfTargetMonth = DateTime(targetYear, date.month + 1, 0).day;
  return DateTime(
    targetYear,
    date.month,
    date.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : date.day,
  );
}

bool isAllowedInspectionDate(DateTime selectedDate, DateTime utcNow) {
  final firstDate = lagosCalendarDate(utcNow);
  final lastDate = addOneCalendarYearClamped(firstDate);
  final selected = DateTime.utc(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  return !selected.isBefore(
        DateTime.utc(firstDate.year, firstDate.month, firstDate.day),
      ) &&
      !selected.isAfter(
        DateTime.utc(lastDate.year, lastDate.month, lastDate.day),
      );
}

String formatInspectionDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String formatInspectionTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
