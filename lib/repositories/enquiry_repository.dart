import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/enquiry.dart';

class EnquiryRepository {
  EnquiryRepository._();

  static final EnquiryRepository instance = EnquiryRepository._();

  Future<void> addEnquiry(Enquiry enquiry) async {
    final propertyId = enquiry.propertyId;
    if (propertyId == null || propertyId <= 0) {
      throw StateError('A published property is required for an enquiry.');
    }

    await Supabase.instance.client.from('Enquiries').insert({
      'property_id': propertyId,
      'property_title': enquiry.propertyTitle,
      'property_location': enquiry.propertyLocation,
      'name': enquiry.name,
      'phone': enquiry.phone,
      'email': enquiry.email,
      'message': enquiry.message,
    });
  }
}
