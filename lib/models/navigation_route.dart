import 'package:latlong2/latlong.dart';

class NavigationStep {
  final String instruction;
  final double distanceMeters;
  final LatLng? maneuverPoint;

  const NavigationStep({
    required this.instruction,
    required this.distanceMeters,
    this.maneuverPoint,
  });
}

class NavigationRoute {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final List<NavigationStep> steps;

  NavigationRoute({
    required List<LatLng> points,
    required this.distanceMeters,
    required this.durationSeconds,
    required List<NavigationStep> steps,
  }) : points = List.unmodifiable(points),
       steps = List.unmodifiable(steps);

  String get formattedDistance {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return remainingMinutes == 0
        ? '$hours hr'
        : '$hours hr $remainingMinutes min';
  }
}
