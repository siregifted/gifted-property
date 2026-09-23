class Property {
  final String title;
  final String location;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final String propertyType;
  final String description;
  final List<String> imageUrls;
  final List<String> features;
  final String status;

  const Property({
    required this.title,
    required this.location,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.propertyType,
    required this.description,
    required this.imageUrls,
    required this.features,
    required this.status,
  });
}
