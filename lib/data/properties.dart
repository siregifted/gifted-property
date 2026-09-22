import '../models/property.dart';

const List<Property> properties = [
  Property(
    title: '5 Bedroom Luxury Home',
    location: 'Katampe, Abuja',
    price: 400000000,
    bedrooms: 5,
    bathrooms: 6,
    propertyType: 'Detached Duplex',
    description:
        'A premium 5 bedroom luxury home designed for comfortable living and long term value.',
    imageUrl: '',
    features: [
      '5 Bedrooms',
      '6 Bathrooms',
      'Spacious Living Areas',
      'Premium Finishes',
      'Secure Estate',
    ],
    status: 'Available',
  ),

  Property(
    title: '4 Bedroom Terrace Duplex',
    location: 'Guzape, Abuja',
    price: 250000000,
    bedrooms: 4,
    bathrooms: 5,
    propertyType: 'Terrace Duplex',
    description:
        'A contemporary 4 bedroom terrace duplex in a premium Abuja location.',
    imageUrl: '',
    features: [
      '4 Bedrooms',
      '5 Bathrooms',
      'Modern Design',
      'Fitted Kitchen',
      'Secure Estate',
    ],
    status: 'Available',
  ),

  Property(
    title: 'Off Plan Villa',
    location: 'Jahi, Abuja',
    price: 200000000,
    bedrooms: 4,
    bathrooms: 5,
    propertyType: 'Off Plan Villa',
    description:
        'An off plan villa opportunity designed for buyers seeking modern living and property investment.',
    imageUrl: '',
    features: [
      '4 Bedrooms',
      '5 Bathrooms',
      'Off Plan',
      'Modern Architecture',
      'Investment Opportunity',
    ],
    status: 'Off Plan',
  ),
];