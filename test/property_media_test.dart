import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/models/property.dart';
import 'package:gifted_property/models/property_media.dart';

void main() {
  test('approved cover media sorts first and video remains typed', () {
    final photo = PropertyMedia.fromMap({
      'id': 2,
      'property_id': 41,
      'media_url': 'https://cdn.example.test/room.jpg',
      'media_type': 'image',
      'sort_order': 1,
      'is_cover': false,
      'is_approved': true,
      'caption': 'Living room',
    });
    final video = PropertyMedia.fromMap({
      'id': 3,
      'property_id': 41,
      'media_url': 'https://cdn.example.test/tour.mp4',
      'media_type': 'video',
      'sort_order': 2,
      'is_cover': true,
      'is_approved': true,
    });
    final unapproved = PropertyMedia.fromMap({
      'id': 4,
      'property_id': 41,
      'media_url': 'https://cdn.example.test/draft.jpg',
      'media_type': 'image',
      'sort_order': 0,
      'is_approved': false,
    });
    final property = Property(
      id: 41,
      title: 'Verified property',
      location: 'Maitama, Abuja',
      price: 1,
      bedrooms: 1,
      bathrooms: 1,
      propertyType: 'Apartment',
      description: 'Test record',
      imageUrls: const [],
      mediaItems: [photo, video, unapproved],
      features: const [],
      status: 'Available',
    );

    expect(property.galleryMedia, [video, photo]);
    expect(property.coverMedia, video);
    expect(property.displayImageUrls, ['https://cdn.example.test/room.jpg']);
    expect(video.isVideo, isTrue);
    expect(photo.caption, 'Living room');
  });

  test('nonpositive IDs are dropped and galleries remain capped', () {
    for (final id in [0, -1]) {
      expect(Property.fromMap({'id': id}).id, isNull);
    }

    final media = List.generate(
      Property.maxGalleryItems + 3,
      (index) => PropertyMedia(
        id: index + 1,
        propertyId: 41,
        url: 'https://cdn.example.test/photo-$index.jpg',
        type: PropertyMediaType.image,
        sortOrder: index,
        isCover: index == Property.maxGalleryItems + 2,
        isApproved: true,
      ),
    );
    final property = Property(
      id: 41,
      title: 'Gallery cap test',
      location: 'Abuja',
      price: 0,
      bedrooms: 0,
      bathrooms: 0,
      propertyType: 'Apartment',
      description: '',
      imageUrls: const [],
      mediaItems: media,
      features: const [],
      status: 'Available',
    );

    expect(property.galleryMedia, hasLength(Property.maxGalleryItems));
    expect(property.galleryMedia.first.id, media.last.id);
  });

  test('media parser rejects insecure URLs and unsupported media types', () {
    expect(
      () => PropertyMedia.fromMap({
        'media_url': 'http://cdn.example.test/photo.jpg',
        'media_type': 'image',
      }),
      throwsFormatException,
    );
    expect(
      () => PropertyMedia.fromMap({
        'media_url': 'https://cdn.example.test/photo.jpg',
        'media_type': 'document',
      }),
      throwsFormatException,
    );
  });

  test('raw address and coordinates are withheld for unverified locations', () {
    final property = Property.fromMap({
      'id': 7,
      'title': 'Test listing',
      'location': 'Maitama, Abuja',
      'address': '12 Example Street',
      'latitude': 9.0,
      'longitude': 7.0,
      'location_verification_status': 'unverified',
    });

    expect(property.location, 'Maitama, Abuja');
    expect(property.verifiedAddress, isNull);
    expect(property.hasVerifiedLocation, isFalse);

    final noPublicLocation = Property.fromMap({
      'title': 'Test listing',
      'address': '12 Example Street',
      'location_verification_status': 'unverified',
    });
    expect(noPublicLocation.location, 'Location available on request');
  });

  test(
    'address is only retained for verified status with valid coordinates',
    () {
      final verified = Property.fromMap({
        'title': 'Verified listing',
        'location': 'Asokoro, Abuja',
        'address': 'A confirmed address',
        'latitude': 9.0,
        'longitude': 7.0,
        'location_verification_status': 'verified',
      });
      final invalidCoordinates = Property.fromMap({
        'title': 'Incomplete listing',
        'location': 'Asokoro, Abuja',
        'address': 'A confirmed address',
        'location_verification_status': 'verified',
      });

      expect(verified.hasVerifiedLocation, isTrue);
      expect(verified.verifiedAddress, 'A confirmed address');
      expect(invalidCoordinates.hasVerifiedLocation, isFalse);
      expect(invalidCoordinates.verifiedAddress, isNull);
    },
  );
}
