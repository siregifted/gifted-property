import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/property.dart';

class PropertyLocationMap extends StatelessWidget {
  final Property property;

  const PropertyLocationMap({super.key, required this.property});

  Future<void> _openDirections(BuildContext context) async {
    final lat = property.latitude;
    final lng = property.longitude;
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSample = property.title.startsWith('SAMPLE ONLY —');
    if (!property.hasCoordinates) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E6EC)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_searching, color: Color(0xFF0B1F33), size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'A map will appear when the property coordinates have been confirmed. We do not guess property locations.',
                style: TextStyle(height: 1.45, color: Color(0xFF334155)),
              ),
            ),
          ],
        ),
      );
    }

    final point = LatLng(property.latitude!, property.longitude!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 14,
                minZoom: 3,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.giftedproperty.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 48,
                      height: 56,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF0B1F33),
                        size: 48,
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                      onTap: () => launchUrl(
                        Uri.parse('https://www.openstreetmap.org/copyright'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              property.hasVerifiedLocation ? Icons.verified : Icons.info_outline,
              color: property.hasVerifiedLocation
                  ? const Color(0xFF16794B)
                  : const Color(0xFF8A5A00),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSample
                    ? 'DEMO ONLY: this is an approximate neighbourhood test pin, not a real property address. Do not use it to arrange a viewing.'
                    : property.hasVerifiedLocation
                        ? 'Location verified by the Gifted Property team'
                        : 'Approximate or unverified location — confirm with our team before travelling',
                style: const TextStyle(height: 1.4),
              ),
            ),
          ],
        ),
        if (property.nearbyLandmarks.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            'Nearby landmarks',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B1F33),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: property.nearbyLandmarks
                .map((landmark) => Chip(
                      avatar: const Icon(Icons.place_outlined, size: 16),
                      label: Text(landmark),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openDirections(context),
            icon: const Icon(Icons.directions_outlined),
            label: Text(isSample ? 'Test approximate area in Maps' : 'Get directions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0B1F33),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
