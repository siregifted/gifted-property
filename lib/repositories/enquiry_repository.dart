import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/enquiry.dart';

class EnquiryRepository {
  EnquiryRepository._();

  static final EnquiryRepository instance = EnquiryRepository._();

  Future<void> addEnquiry(Enquiry enquiry) async {
    await Supabase.instance.client.from('Enquiries').insert({
      'property_id': enquiry.propertyId,
      'property_title': enquiry.propertyTitle,
      'property_location': enquiry.propertyLocation,
      'name': enquiry.name,
      'phone': enquiry.phone,
      'email': enquiry.email,
      'message': enquiry.message,
    });
  }
}
