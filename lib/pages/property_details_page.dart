import 'package:flutter/material.dart';

import '../models/property.dart';

class PropertyDetailsPage extends StatelessWidget {
  final Property property;

  const PropertyDetailsPage({
    super.key,
    required this.property,
  });

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '₦${(price / 1000000).toStringAsFixed(0)}M';
    }

    return '₦$price';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        title: const Text(
          'Property Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 400,
                  color: const Color(0xFFE8EEF3),
                  child: const Icon(
                    Icons.home_work,
                    size: 120,
                    color: Color(0xFF0B1F33),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1F33),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            property.location,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _formatPrice(property.price),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1F33),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _infoChip(
                            Icons.bed_outlined,
                            '${property.bedrooms} Bedrooms',
                          ),
                          _infoChip(
                            Icons.bathtub_outlined,
                            '${property.bathrooms} Bathrooms',
                          ),
                          _infoChip(
                            Icons.home_outlined,
                            property.propertyType,
                          ),
                          _infoChip(
                            Icons.verified_outlined,
                            property.status,
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1F33),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        property.description,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 35),
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1F33),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ...property.features.map(
                        (feature) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Color(0xFF0B1F33),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF0B1F33),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                              child: const Text(
                                'Schedule Inspection',
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    const Color(0xFF0B1F33),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                              child: const Text(
                                'Contact Agent',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFF0B1F33),
          ),
          const SizedBox(width: 7),
          Text(label),
        ],
      ),
    );
  }
}