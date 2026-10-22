import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/property.dart';

class PropertyRepository {
  const PropertyRepository();

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Property>> getPublishedProperties() async {
    final rows = await _client
        .from('Properties')
        .select()
        .eq('is_published', true)
        .order('created_at', ascending: false);
    return _attachApprovedMedia(rows);
  }

  Future<List<Property>> getFeaturedProperties() async {
    final rows = await _client
        .from('Properties')
        .select()
        .eq('is_published', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false);
    return _attachApprovedMedia(rows);
  }

  Future<List<Property>> _attachApprovedMedia(List<dynamic> rows) async {
    final properties = rows
        .map((row) => Property.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
    final ids = properties.map((property) => property.id).whereType<int>().toList();
    if (ids.isEmpty) return properties;

    try {
      final mediaRows = await _client
          .from('PropertyMedia')
          .select('property_id, media_url, sort_order, is_approved')
          .inFilter('property_id', ids)
          .eq('is_approved', true)
          .order('sort_order', ascending: true);

      final urlsByProperty = <int, List<String>>{};
      for (final row in mediaRows) {
        final item = Map<String, dynamic>.from(row as Map);
        final propertyId = (item['property_id'] as num?)?.toInt();
        final url = item['media_url']?.toString().trim() ?? '';
        if (propertyId == null || url.isEmpty) continue;
        urlsByProperty.putIfAbsent(propertyId, () => <String>[]).add(url);
      }

      return properties.map((property) {
        final mediaUrls = property.id == null
            ? null
            : urlsByProperty[property.id!];
        if (mediaUrls == null || mediaUrls.isEmpty) return property;
        return Property(
          id: property.id,
          title: property.title,
          location: property.location,
          price: property.price,
          bedrooms: property.bedrooms,
          bathrooms: property.bathrooms,
          propertyType: property.propertyType,
          description: property.description,
          imageUrls: mediaUrls,
          features: property.features,
          status: property.status,
          isFeatured: property.isFeatured,
          latitude: property.latitude,
          longitude: property.longitude,
          locationVerificationStatus: property.locationVerificationStatus,
          nearbyLandmarks: property.nearbyLandmarks,
        );
      }).toList();
    } on PostgrestException {
      // Keep the legacy image_url fallback if the optional media table has not
      // been migrated yet. The migration is included in this feature branch.
      return properties;
    }
  }
}
