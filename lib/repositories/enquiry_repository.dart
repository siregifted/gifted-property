import '../models/enquiry.dart';

class EnquiryRepository {
  EnquiryRepository._();

  static final EnquiryRepository instance = EnquiryRepository._();

  final List<Enquiry> _enquiries = [];

  List<Enquiry> getEnquiries() {
    return List.unmodifiable(_enquiries);
  }

  void addEnquiry(Enquiry enquiry) {
    _enquiries.add(enquiry);
  }
}
