import 'property_media.dart';

class Property {
  static const int maxGalleryItems = 8;

  final int? id;
  final String title;
  final String location;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final String propertyType;
  final String description;
  final List<String> imageUrls;
  final List<PropertyMedia> mediaItems;
  final List<String> features;
  final String status;
  final bool isFeatured;
  final bool isSample;
  final double? latitude;
  final double? longitude;
  final String locationVerificationStatus;
  final String? verifiedAddress;
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
    this.mediaItems = const [],
    required this.features,
    required this.status,
    this.isFeatured = false,
    this.isSample = false,
    this.latitude,
    this.longitude,
    this.locationVerificationStatus = 'unverified',
    this.verifiedAddress,
    this.nearbyLandmarks = const [],
  });

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180;

  bool get hasVerifiedLocation =>
      hasCoordinates && locationVerificationStatus == 'verified';

  List<PropertyMedia> get galleryMedia {
    final media = mediaItems.isNotEmpty
        ? mediaItems.where((item) => item.isApproved).toList()
        : imageUrls
              .map((url) => url.trim())
              .where((url) {
                final uri = Uri.tryParse(url);
                return uri != null &&
                    uri.scheme == 'https' &&
                    uri.host.isNotEmpty;
              })
              .map(
                (url) => PropertyMedia(
                  url: url,
                  type: PropertyMediaType.image,
                  isCover: false,
                  isApproved: true,
                ),
              )
              .toList();
    media.sort();
    return List<PropertyMedia>.unmodifiable(media.take(maxGalleryItems));
  }

  PropertyMedia? get coverMedia =>
      galleryMedia.isEmpty ? null : galleryMedia.first;

  List<String> get displayImageUrls => galleryMedia
      .where((item) => item.isImage)
      .map((item) => item.url)
      .toList(growable: false);

  Property copyWith({
    List<String>? imageUrls,
    List<PropertyMedia>? mediaItems,
  }) {
    return Property(
      id: id,
      title: title,
      location: location,
      price: price,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      propertyType: propertyType,
      description: description,
      imageUrls: imageUrls ?? this.imageUrls,
      mediaItems: mediaItems ?? this.mediaItems,
      features: features,
      status: status,
      isFeatured: isFeatured,
      isSample: isSample,
      latitude: latitude,
      longitude: longitude,
      locationVerificationStatus: locationVerificationStatus,
      verifiedAddress: verifiedAddress,
      nearbyLandmarks: nearbyLandmarks,
    );
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    final status =
        map['location_verification_status']?.toString() ?? 'unverified';
    final rawAddress = map['address']?.toString().trim() ?? '';
    final latitude = _asDouble(map['latitude']);
    final longitude = _asDouble(map['longitude']);
    final hasValidCoordinates =
        latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
    final priceValue = map['price'];
    final bedroomsValue = map['bedrooms'];
    final bathroomsValue = map['bathrooms'];
    final rawFeatures = map['features'];
    final rawLandmarks = map['nearby_landmarks'];

    return Property(
      id: _asPositiveInt(map['id']),
      title: map['title']?.toString() ?? '',
      // Never fall back to a raw street address for the public location label.
      location: map['location']?.toString() ?? 'Location available on request',
      price: _asInt(priceValue) ?? 0,
      bedrooms: _asInt(bedroomsValue) ?? 0,
      bathrooms: _asInt(bathroomsValue) ?? 0,
      propertyType: map['property_type']?.toString() ?? 'Property',
      description: map['description']?.toString() ?? '',
      // Legacy image_url values are not trusted as approved media.
      imageUrls: const [],
      features: rawFeatures is List
          ? rawFeatures.map((item) => item.toString()).toList()
          : const [],
      status: map['status']?.toString() ?? 'Available',
      isFeatured: map['is_featured'] == true,
      isSample: map['is_sample'] == true,
      latitude: latitude,
      longitude: longitude,
      locationVerificationStatus: status,
      verifiedAddress:
          status == 'verified' && hasValidCoordinates && rawAddress.isNotEmpty
          ? rawAddress
          : null,
      nearbyLandmarks: rawLandmarks is List
          ? rawLandmarks.map((item) => item.toString()).toList()
          : const [],
    );
  }

  static int? _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static int? _asPositiveInt(dynamic value) {
    final id = _asInt(value);
    return id != null && id > 0 ? id : null;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
