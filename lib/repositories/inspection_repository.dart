import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inspection.dart';
import '../validation/lead_validators.dart';

class InspectionRepository {
  InspectionRepository._();

  static final InspectionRepository instance = InspectionRepository._();

  Future<void> addInspection(Inspection inspection) async {
    final propertyId = inspection.propertyId;
    if (propertyId == null || propertyId <= 0) {
      throw StateError('A published property is required for an inspection.');
    }
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$')
        .hasMatch(inspection.preferredTime)) {
      throw ArgumentError.value(
        inspection.preferredTime,
        'preferredTime',
        'Use a 24-hour HH:mm time in Abuja time.',
      );
    }

    await Supabase.instance.client.from('Inspections').insert({
      'property_id': propertyId,
      'property_title': inspection.propertyTitle,
      'property_location': inspection.propertyLocation,
      'name': inspection.name,
      'phone': inspection.phone,
      'email': inspection.email,
      'inspection_date': formatInspectionDate(inspection.inspectionDate),
      'preferred_time': inspection.preferredTime,
      'message': inspection.message,
    });
  }
}
