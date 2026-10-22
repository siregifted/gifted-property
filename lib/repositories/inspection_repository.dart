import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inspection.dart';

class InspectionRepository {
  InspectionRepository._();

  static final InspectionRepository instance = InspectionRepository._();

  Future<void> addInspection(Inspection inspection) async {
    final date = inspection.inspectionDate;
    final formattedDate =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    await Supabase.instance.client.from('Inspections').insert({
      'property_id': inspection.propertyId,
      'property_title': inspection.propertyTitle,
      'property_location': inspection.propertyLocation,
      'name': inspection.name,
      'phone': inspection.phone,
      'email': inspection.email,
      'inspection_date': formattedDate,
      'preferred_time': inspection.preferredTime,
      'message': inspection.message,
    });
  }
}
