class Enquiry {
  final int? propertyId;
  final String propertyTitle;
  final String propertyLocation;
  final String name;
  final String phone;
  final String email;
  final String message;

  const Enquiry({
    this.propertyId,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.name,
    required this.phone,
    required this.email,
    required this.message,
  });
}
