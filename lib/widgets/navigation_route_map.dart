import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/map_tiles_config.dart';
import '../models/navigation_route.dart';

class NavigationRouteMap extends StatelessWidget {
  final MapController controller;
  final LatLng destination;
  final LatLng? currentLocation;
  final NavigationRoute? route;
  final bool approximateDestination;
  final String? maneuverInstruction;
  final double? distanceToManeuverMeters;

  const NavigationRouteMap({
    super.key,
    required this.controller,
    required this.destination,
    required this.currentLocation,
    required this.route,
    required this.approximateDestination,
    this.maneuverInstruction,
    this.distanceToManeuverMeters,
  });

  @override
  Widget build(BuildContext context) {
    final initialPoints = <LatLng>[
      if (route != null) ...route!.points,
      ?currentLocation,
      destination,
    ];
    final initialFit = route == null || initialPoints.length < 2
        ? null
        : CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(initialPoints),
            padding: const EdgeInsets.all(64),
            maxZoom: 16,
          );

    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          key: ObjectKey(route),
          options: MapOptions(
            initialCenter: currentLocation ?? destination,
            initialZoom: route == null ? 14 : 12,
            initialCameraFit: initialFit,
            minZoom: 3,
            maxZoom: 19,
          ),
          children: [
            TileLayer(
              urlTemplate: MapTilesConfig.urlTemplate,
              additionalOptions: MapTilesConfig.additionalOptions,
              userAgentPackageName: MapTilesConfig.userAgentPackageName,
            ),
            if (route != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: route!.points,
                    strokeWidth: 7,
                    color: const Color(0xFF16794B),
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (currentLocation != null)
                  Marker(
                    point: currentLocation!,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2878E3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 7),
                        ],
                      ),
                    ),
                  ),
                Marker(
                  point: destination,
                  width: 54,
                  height: 60,
                  child: Icon(
                    approximateDestination
                        ? Icons.location_searching
                        : Icons.location_on,
                    color: approximateDestination
                        ? const Color(0xFFB7791F)
                        : const Color(0xFF0B1F33),
                    size: 50,
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
                TextSourceAttribution(
                  'Routing by OSRM',
                  onTap: () => launchUrl(
                    Uri.parse('https://project-osrm.org/'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (maneuverInstruction != null)
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: _ManeuverCard(
              instruction: maneuverInstruction!,
              distanceMeters: distanceToManeuverMeters,
            ),
          ),
        if (currentLocation != null)
          Positioned(
            right: 14,
            bottom: 48,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: IconButton(
                tooltip: 'Recenter on my location',
                onPressed: () => controller.move(currentLocation!, 16),
                icon: const Icon(Icons.my_location, color: Color(0xFF0B1F33)),
              ),
            ),
          ),
      ],
    );
  }
}

class _ManeuverCard extends StatelessWidget {
  final String instruction;
  final double? distanceMeters;

  const _ManeuverCard({required this.instruction, this.distanceMeters});

  @override
  Widget build(BuildContext context) {
    final distanceText = distanceMeters == null
        ? null
        : distanceMeters! < 1000
        ? '${distanceMeters!.round()} m'
        : '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
    return Card(
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            const Icon(Icons.turn_right, color: Color(0xFF0B1F33), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                instruction,
                style: const TextStyle(
                  color: Color(0xFF0B1F33),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            if (distanceText != null) ...[
              const SizedBox(width: 8),
              Text(
                distanceText,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
