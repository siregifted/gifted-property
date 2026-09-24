class Enquiry {
  final String propertyTitle;
  final String propertyLocation;
  final String name;
  final String phone;
  final String email;
  final String message;
  final DateTime createdAt;

  const Enquiry({
    required this.propertyTitle,
    required this.propertyLocation,
    required this.name,
    required this.phone,
    required this.email,
    required this.message,
    required this.createdAt,
  });
}
