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
    return rows.map((row) => Property.fromMap(row)).toList();
  }

  Future<List<Property>> getFeaturedProperties() async {
    final rows = await _client
        .from('Properties')
        .select()
        .eq('is_published', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false);
    return rows.map((row) => Property.fromMap(row)).toList();
  }
}
