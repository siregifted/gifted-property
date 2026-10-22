class Property {
  final int? id;
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
  final bool isFeatured;

  const Property({
    this.id,
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
    this.isFeatured = false,
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    final imageUrl = map['image_url']?.toString().trim() ?? '';
    final priceValue = map['price'];
    final bedroomsValue = map['bedrooms'];
    final bathroomsValue = map['bathrooms'];

    return Property(
      id: (map['id'] as num?)?.toInt(),
      title: map['title']?.toString() ?? '',
      location: (map['location'] ?? map['address'] ?? '').toString(),
      price: priceValue is num
          ? priceValue.toInt()
          : int.tryParse(priceValue?.toString() ?? '') ?? 0,
      bedrooms: bedroomsValue is num
          ? bedroomsValue.toInt()
          : int.tryParse(bedroomsValue?.toString() ?? '') ?? 0,
      bathrooms: bathroomsValue is num
          ? bathroomsValue.toInt()
          : int.tryParse(bathroomsValue?.toString() ?? '') ?? 0,
      propertyType: map['property_type']?.toString() ?? 'Property',
      description: map['description']?.toString() ?? '',
      imageUrls: imageUrl.isEmpty ? const [] : [imageUrl],
      features: const [],
      status: map['status']?.toString() ?? 'Available',
      isFeatured: map['is_featured'] == true,
    );
  }
}
