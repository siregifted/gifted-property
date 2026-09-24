class Inspection {
  final String propertyTitle;
  final String propertyLocation;
  final String name;
  final String phone;
  final String email;
  final DateTime inspectionDate;
  final String preferredTime;
  final String message;
  final DateTime createdAt;

  const Inspection({
    required this.propertyTitle,
    required this.propertyLocation,
    required this.name,
    required this.phone,
    required this.email,
    required this.inspectionDate,
    required this.preferredTime,
    required this.message,
    required this.createdAt,
  });
}
