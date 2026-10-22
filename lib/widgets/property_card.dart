import 'package:flutter/material.dart';

import '../models/property.dart';
import '../models/property_media.dart';
import '../pages/property_details_page.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '₦${(price / 1000000).toStringAsFixed(0)}M';
    }

    return '₦$price';
  }

  @override
  Widget build(BuildContext context) {
    final media = property.coverMedia;
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailsPage(property: property),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: _buildCover(media),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (property.isSample) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'DEMO ONLY — fictional listing and price; not for sale',
                      style: TextStyle(
                        color: Color(0xFF8A5A00),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatPrice(property.price),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1F33),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bed_outlined, size: 18),
                          const SizedBox(width: 4),
                          Text('${property.bedrooms} Beds'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bathtub_outlined, size: 18),
                          const SizedBox(width: 4),
                          Text('${property.bathrooms} Baths'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'View Details →',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1F33),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(PropertyMedia? media) {
    if (media == null) {
      return const ColoredBox(
        color: Color(0xFFE8EEF3),
        child: Center(
          child: Icon(Icons.home_work, size: 70, color: Color(0xFF0B1F33)),
        ),
      );
    }

    if (media.isVideo) {
      return const ColoredBox(
        color: Color(0xFF102A43),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
              SizedBox(height: 8),
              Text('Property video', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return Image.network(
      media.url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: Color(0xFFE8EEF3),
          child: Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: Color(0xFFE8EEF3),
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 70,
            color: Color(0xFF0B1F33),
          ),
        ),
      ),
    );
  }
}
