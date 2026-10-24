import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/map_tiles_config.dart';
import '../models/property.dart';
import '../pages/property_navigation_page.dart';
import '../validation/navigation_policy.dart';

class PropertyLocationMap extends StatelessWidget {
  final Property property;

  const PropertyLocationMap({super.key, required this.property});

  bool get _hasApproximatePin =>
      property.locationVerificationStatus == 'approximate' &&
      property.hasCoordinates;

  bool get _canShowPin =>
      property.isSample || property.hasVerifiedLocation || _hasApproximatePin;

  bool get _canPreviewRoute => canPreviewPropertyRoute(property);

  String get _locationNotice {
    if (property.isSample) {
      return 'DEMO ONLY: fictional listing and approximate neighbourhood pin. '
          'This is not a real property address and must not be used to arrange a viewing.';
    }
    if (property.hasVerifiedLocation) {
      return 'Location marked verified. Confirm access details with Gifted Property before travelling.';
    }
    if (_hasApproximatePin) {
      return 'Approximate neighbourhood location only — this pin is not an exact property address. '
          'Confirm the location with our team before travelling.';
    }
    return 'The property location has not been verified. Map pins and directions are withheld '
        'until the location is reviewed.';
  }

  Future<void> _openDirections(BuildContext context) async {
    if (!_canShowPin) return;
    final lat = property.latitude;
    final lng = property.longitude;
    if (lat == null || lng == null) return;

    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$lat,$lng',
    });
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps on this device.')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!property.hasCoordinates || !_canShowPin) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E6EC)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_searching,
              color: Color(0xFF0B1F33),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                property.locationVerificationStatus == 'verified' &&
                        !property.hasCoordinates
                    ? 'This listing is marked verified, but valid coordinates are missing. '
                          'The map and directions are withheld until the data is corrected.'
                    : _locationNotice,
                style: const TextStyle(height: 1.45, color: Color(0xFF334155)),
              ),
            ),
          ],
        ),
      );
    }

    final point = LatLng(property.latitude!, property.longitude!);
    final directionLabel = _hasApproximatePin
        ? 'Open approximate area in Maps'
        : 'Open directions in Maps';

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
                initialZoom: _hasApproximatePin || property.isSample ? 12 : 14,
                minZoom: 3,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: MapTilesConfig.urlTemplate,
                  additionalOptions: MapTilesConfig.additionalOptions,
                  userAgentPackageName: MapTilesConfig.userAgentPackageName,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 48,
                      height: 56,
                      child: Icon(
                        property.hasVerifiedLocation
                            ? Icons.location_on
                            : Icons.location_searching,
                        color: property.hasVerifiedLocation
                            ? const Color(0xFF0B1F33)
                            : const Color(0xFF8A5A00),
                        size: 48,
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      MapTilesConfig.attributionText,
                      prependCopyright: false,
                      onTap: () => launchUrl(
                        Uri.parse(MapTilesConfig.attributionUrl),
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
              property.hasVerifiedLocation
                  ? Icons.verified
                  : Icons.info_outline,
              color: property.hasVerifiedLocation
                  ? const Color(0xFF16794B)
                  : const Color(0xFF8A5A00),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_locationNotice, style: const TextStyle(height: 1.4)),
            ),
          ],
        ),
        if (property.nearbyLandmarks.isNotEmpty &&
            (property.hasVerifiedLocation || _hasApproximatePin)) ...[
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
                .map(
                  (landmark) => Chip(
                    avatar: const Icon(Icons.place_outlined, size: 16),
                    label: Text(landmark),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 12),
        if (property.isSample)
          const Text(
            'Demo sample — navigation is disabled.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF704E00),
              fontWeight: FontWeight.w700,
            ),
          )
        else if (_canPreviewRoute) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PropertyNavigationPage(property: property),
                ),
              ),
              icon: const Icon(Icons.navigation_outlined),
              label: const Text('Preview route in Gifted Property'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B1F33),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openDirections(context),
              icon: const Icon(Icons.open_in_new),
              label: Text(directionLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0B1F33),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
