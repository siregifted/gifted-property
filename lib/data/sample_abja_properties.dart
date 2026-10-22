import '../models/property.dart';

/// Development-only demo listings for testing the Abuja catalogue and map UI.
///
/// These are not real properties or offers for sale. Coordinates point only to
/// approximate neighbourhood areas, not to property addresses. Keep these
/// fixtures behind USE_SAMPLE_PROPERTIES so they cannot appear in production.
const List<Property> sampleAbujaProperties = [
  Property(
    title: 'SAMPLE ONLY — 3-Bedroom Apartment, Maitama',
    location: 'Maitama, Abuja (approximate area pin)',
    price: 180000000,
    bedrooms: 3,
    bathrooms: 3,
    propertyType: 'Apartment',
    description:
        'DEMO LISTING ONLY. This fictional record is for testing the Gifted Property app. It is not a real property, is not being offered for sale, and must not be used to arrange a viewing. The map pin indicates only an approximate neighbourhood area.',
    imageUrls: [],
    features: [
      'Sample data — not for sale',
      'Approximate neighbourhood map pin',
      'No real property address supplied',
    ],
    status: 'Sample — not for sale',
    isFeatured: true,
    latitude: 9.091,
    longitude: 7.496,
    locationVerificationStatus: 'approximate',
  ),
  Property(
    title: 'SAMPLE ONLY — 4-Bedroom Terrace, Guzape',
    location: 'Guzape, Abuja (approximate area pin)',
    price: 250000000,
    bedrooms: 4,
    bathrooms: 4,
    propertyType: 'Terrace',
    description:
        'DEMO LISTING ONLY. This fictional record is for testing the Gifted Property app. It is not a real property, is not being offered for sale, and must not be used to arrange a viewing. The map pin indicates only an approximate neighbourhood area.',
    imageUrls: [],
    features: [
      'Sample data — not for sale',
      'Approximate neighbourhood map pin',
      'No real property address supplied',
    ],
    status: 'Sample — not for sale',
    isFeatured: true,
    latitude: 9.035,
    longitude: 7.514,
    locationVerificationStatus: 'approximate',
  ),
  Property(
    title: 'SAMPLE ONLY — 3-Bedroom Home, Gwarinpa',
    location: 'Gwarinpa, Abuja (approximate area pin)',
    price: 95000000,
    bedrooms: 3,
    bathrooms: 3,
    propertyType: 'Detached House',
    description:
        'DEMO LISTING ONLY. This fictional record is for testing the Gifted Property app. It is not a real property, is not being offered for sale, and must not be used to arrange a viewing. The map pin indicates only an approximate neighbourhood area.',
    imageUrls: [],
    features: [
      'Sample data — not for sale',
      'Approximate neighbourhood map pin',
      'No real property address supplied',
    ],
    status: 'Sample — not for sale',
    isFeatured: true,
    latitude: 9.105,
    longitude: 7.414,
    locationVerificationStatus: 'approximate',
  ),
];
