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
  final double? latitude;
  final double? longitude;
  final String locationVerificationStatus;
  final List<String> nearbyLandmarks;

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
    this.latitude,
    this.longitude,
    this.locationVerificationStatus = 'unverified',
    this.nearbyLandmarks = const [],
  });

  bool get hasCoordinates => latitude != null &&
      longitude != null &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180;

  bool get hasVerifiedLocation =>
      hasCoordinates && locationVerificationStatus == 'verified';

  factory Property.fromMap(Map<String, dynamic> map) {
    final imageUrl = map['image_url']?.toString().trim() ?? '';
    final priceValue = map['price'];
    final bedroomsValue = map['bedrooms'];
    final bathroomsValue = map['bathrooms'];
    final rawFeatures = map['features'];
    final rawLandmarks = map['nearby_landmarks'];

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
      features: rawFeatures is List
          ? rawFeatures.map((item) => item.toString()).toList()
          : const [],
      status: map['status']?.toString() ?? 'Available',
      isFeatured: map['is_featured'] == true,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationVerificationStatus:
          map['location_verification_status']?.toString() ?? 'unverified',
      nearbyLandmarks: rawLandmarks is List
          ? rawLandmarks.map((item) => item.toString()).toList()
          : const [],
    );
  }
}
