enum PropertyMediaType { image, video }

class PropertyMedia implements Comparable<PropertyMedia> {
  final int? id;
  final int? propertyId;
  final String url;
  final PropertyMediaType type;
  final int sortOrder;
  final bool isCover;
  final bool isApproved;
  final String? caption;

  const PropertyMedia({
    this.id,
    this.propertyId,
    required this.url,
    required this.type,
    this.sortOrder = 0,
    this.isCover = false,
    this.isApproved = false,
    this.caption,
  });

  bool get isImage => type == PropertyMediaType.image;
  bool get isVideo => type == PropertyMediaType.video;

  factory PropertyMedia.fromMap(Map<String, dynamic> map) {
    final url = map['media_url']?.toString().trim() ?? '';
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('Property media must use a valid HTTPS URL.');
    }

    final type = switch (map['media_type']?.toString().toLowerCase()) {
      'image' => PropertyMediaType.image,
      'video' => PropertyMediaType.video,
      _ => throw const FormatException('Unsupported property media type.'),
    };
    final caption = map['caption']?.toString().trim();

    return PropertyMedia(
      id: _asInt(map['id']),
      propertyId: _asInt(map['property_id']),
      url: url,
      type: type,
      sortOrder: _asInt(map['sort_order']) ?? 0,
      isCover: map['is_cover'] == true,
      isApproved: map['is_approved'] == true,
      caption: caption == null || caption.isEmpty ? null : caption,
    );
  }

  @override
  int compareTo(PropertyMedia other) {
    if (isCover != other.isCover) return isCover ? -1 : 1;
    final bySortOrder = sortOrder.compareTo(other.sortOrder);
    if (bySortOrder != 0) return bySortOrder;
    return (id ?? 0).compareTo(other.id ?? 0);
  }

  static int? _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
