import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/sample_data_config.dart';
import '../data/sample_abuja_properties.dart';
import '../models/property.dart';
import '../models/property_media.dart';

class PropertyRepository {
  const PropertyRepository();

  static const bool sampleListingsEnabled = sampleDataEnabled;
  static const int maxCatalogRows = 100;
  static const int maxMediaRowsPerFetch =
      maxCatalogRows * Property.maxGalleryItems;

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Property>> getPublishedProperties() async {
    if (sampleListingsEnabled) {
      return List<Property>.unmodifiable(sampleAbujaProperties);
    }

    final rows = await _client
        .from('public_properties')
        .select(
          'id,created_at,title,description,price,property_type,location,'
          'bedrooms,bathrooms,status,is_featured,address,latitude,longitude,'
          'location_verification_status,nearby_landmarks,features',
        )
        .order('created_at', ascending: false)
        .limit(maxCatalogRows);
    return _attachApprovedMedia(rows);
  }

  Future<List<Property>> getFeaturedProperties() async {
    if (sampleListingsEnabled) {
      return List<Property>.unmodifiable(
        sampleAbujaProperties.where((property) => property.isFeatured),
      );
    }

    final rows = await _client
        .from('public_properties')
        .select(
          'id,created_at,title,description,price,property_type,location,'
          'bedrooms,bathrooms,status,is_featured,address,latitude,longitude,'
          'location_verification_status,nearby_landmarks,features',
        )
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(3);
    return _attachApprovedMedia(rows);
  }

  Future<List<Property>> _attachApprovedMedia(List<dynamic> rows) async {
    final properties = rows
        .map((row) => Property.fromMap(Map<String, dynamic>.from(row as Map)))
        .where((property) => property.id != null && property.id! > 0)
        .toList();
    final ids = properties
        .map((property) => property.id)
        .whereType<int>()
        .where((id) => id > 0)
        .toList();
    if (ids.isEmpty) return properties;

    try {
      final mediaRows = await _client
          .from('public_property_media')
          .select(
            'id,property_id,media_url,media_type,sort_order,is_cover,'
            'is_approved,caption',
          )
          .inFilter('property_id', ids)
          .order('is_cover', ascending: false)
          .order('sort_order', ascending: true)
          .order('id', ascending: true)
          .limit(maxMediaRowsPerFetch);

      final mediaByProperty = <int, List<PropertyMedia>>{};
      for (final row in mediaRows) {
        final item = Map<String, dynamic>.from(row as Map);
        try {
          final media = PropertyMedia.fromMap(item);
          if (!media.isApproved || media.propertyId == null) continue;
          final propertyMedia = mediaByProperty.putIfAbsent(
            media.propertyId!,
            () => [],
          );
          if (propertyMedia.length < Property.maxGalleryItems) {
            propertyMedia.add(media);
          }
        } on FormatException catch (error) {
          debugPrint(
            'Ignoring invalid property media record: ${error.message}',
          );
        }
      }

      return properties.map((property) {
        final media = mediaByProperty[property.id] ?? const <PropertyMedia>[];
        return property.copyWith(
          mediaItems: media,
          imageUrls: media
              .where((item) => item.isImage)
              .map((item) => item.url)
              .toList(growable: false),
        );
      }).toList();
    } on PostgrestException catch (error) {
      if (error.code == 'PGRST205' || error.code == '42P01') {
        // Keep published details readable during a staged rollout, but do not
        // bypass the public view or fall back to an unrestricted table query.
        return properties;
      }
      rethrow;
    }
  }
}
