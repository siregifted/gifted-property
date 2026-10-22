import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/models/property.dart';

void main() {
  test('legacy image_url is not treated as approved gallery media', () {
    final property = Property.fromMap({
      'id': 23,
      'title': 'Legacy record',
      'location': 'Abuja',
      'image_url': 'https://cdn.example.test/unreviewed.jpg',
    });

    expect(property.galleryMedia, isEmpty);
    expect(property.displayImageUrls, isEmpty);
  });
}
