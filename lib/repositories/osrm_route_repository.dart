import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/navigation_route.dart';

class OsrmRouteException implements Exception {
  final String message;

  const OsrmRouteException(this.message);

  @override
  String toString() => message;
}

class OsrmRouteRepository {
  final http.Client _client;
  final Uri _baseUri;
  final Duration _timeout;

  OsrmRouteRepository({
    http.Client? client,
    Uri? baseUri,
    this._timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _baseUri = baseUri ?? Uri.https('router.project-osrm.org');

  Future<NavigationRoute> fetchDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (!_isValid(origin) || !_isValid(destination)) {
      throw const OsrmRouteException(
        'A valid start and destination are required.',
      );
    }

    final path =
        '/route/v1/driving/${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';
    final uri = _baseUri.replace(
      path: path,
      queryParameters: const {
        'steps': 'true',
        'overview': 'full',
        'geometries': 'geojson',
        'alternatives': 'false',
      },
    );
    final headers = <String, String>{'Accept': 'application/json'};
    // Browsers own restricted headers such as User-Agent. Native clients can
    // identify the application directly, as requested by the OSRM demo policy.
    if (!kIsWeb) {
      headers['User-Agent'] =
          'GiftedProperty/1.0 (+https://github.com/siregifted/gifted-property)';
    }

    late final http.Response response;
    try {
      response = await _client.get(uri, headers: headers).timeout(_timeout);
    } on TimeoutException {
      throw const OsrmRouteException(
        'The routing service took too long to respond. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const OsrmRouteException(
        'Could not reach the routing service. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200) {
      throw OsrmRouteException(
        'The routing service is temporarily unavailable (HTTP ${response.statusCode}).',
      );
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const OsrmRouteException(
        'The routing service returned an unreadable response.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const OsrmRouteException(
        'The routing service returned an unreadable response.',
      );
    }
    return parseResponse(decoded);
  }

  static NavigationRoute parseResponse(Map<String, dynamic> response) {
    if (response['code'] != 'Ok') {
      final code = response['code'];
      if (code == 'NoRoute') {
        throw const OsrmRouteException(
          'No drivable route was found for this location.',
        );
      }
      throw const OsrmRouteException(
        'The routing service could not calculate this route.',
      );
    }

    final routes = response['routes'];
    if (routes is! List || routes.isEmpty || routes.first is! Map) {
      throw const OsrmRouteException(
        'No route was returned for this location.',
      );
    }
    final route = Map<String, dynamic>.from(routes.first as Map);
    final geometry = route['geometry'];
    final coordinates = geometry is Map ? geometry['coordinates'] : null;
    if (coordinates is! List) {
      throw const OsrmRouteException('The route geometry is missing.');
    }
    final points = <LatLng>[];
    for (final coordinate in coordinates) {
      if (coordinate is! List || coordinate.length < 2) continue;
      final longitude = _number(coordinate[0]);
      final latitude = _number(coordinate[1]);
      if (longitude == null || latitude == null) continue;
      final point = LatLng(latitude, longitude);
      if (_isValid(point)) points.add(point);
    }
    if (points.length < 2) {
      throw const OsrmRouteException('The route geometry is incomplete.');
    }

    final distance = _number(route['distance']);
    final duration = _number(route['duration']);
    if (distance == null || distance < 0 || duration == null || duration < 0) {
      throw const OsrmRouteException('The route metrics are invalid.');
    }

    final steps = <NavigationStep>[];
    final legs = route['legs'];
    if (legs is List) {
      for (final legValue in legs) {
        if (legValue is! Map) continue;
        final leg = Map<String, dynamic>.from(legValue);
        final legSteps = leg['steps'];
        if (legSteps is! List) continue;
        for (final stepValue in legSteps) {
          if (stepValue is! Map) continue;
          final step = Map<String, dynamic>.from(stepValue);
          final maneuver = step['maneuver'];
          if (maneuver is! Map) continue;
          final maneuverMap = Map<String, dynamic>.from(maneuver);
          final location = maneuverMap['location'];
          LatLng? maneuverPoint;
          if (location is List && location.length >= 2) {
            final longitude = _number(location[0]);
            final latitude = _number(location[1]);
            if (longitude != null && latitude != null) {
              final point = LatLng(latitude, longitude);
              if (_isValid(point)) maneuverPoint = point;
            }
          }
          steps.add(
            NavigationStep(
              instruction: _instruction(maneuverMap, step['name']),
              distanceMeters: _number(step['distance']) ?? 0,
              maneuverPoint: maneuverPoint,
            ),
          );
        }
      }
    }

    return NavigationRoute(
      points: points,
      distanceMeters: distance,
      durationSeconds: duration,
      steps: steps,
    );
  }

  static String _instruction(Map<String, dynamic> maneuver, Object? rawName) {
    final type = maneuver['type']?.toString() ?? '';
    final modifier = maneuver['modifier']?.toString() ?? '';
    final name = rawName is String ? rawName.trim() : '';
    final road = name.isEmpty ? '' : ' onto $name';

    if (type == 'depart') {
      return name.isEmpty ? 'Start on the route' : 'Head towards $name';
    }
    if (type == 'arrive') return 'Arrive at the destination';
    if (type == 'roundabout' || type == 'rotary') {
      final exit = maneuver['exit'];
      final exitText = exit is num ? ' and take exit ${exit.round()}' : '';
      return 'Enter the roundabout$exitText$road';
    }

    final direction = switch (modifier) {
      'left' => 'left',
      'slight left' => 'slightly left',
      'sharp left' => 'sharply left',
      'right' => 'right',
      'slight right' => 'slightly right',
      'sharp right' => 'sharply right',
      'uturn' => 'a U-turn',
      'straight' => 'straight',
      _ => '',
    };
    final action = switch (type) {
      'turn' => direction == 'a U-turn' ? 'Make' : 'Turn',
      'continue' => 'Continue',
      'new name' => 'Continue',
      'merge' => 'Merge',
      'fork' => 'Keep',
      'on ramp' => 'Take the ramp',
      'off ramp' => 'Take the exit',
      'end of road' => 'At the end of the road, turn',
      'notification' => 'Continue',
      _ => 'Continue',
    };
    final directionText = direction.isEmpty ? '' : ' $direction';
    return '$action$directionText$road';
  }

  static double? _number(Object? value) =>
      value is num ? value.toDouble() : null;

  static bool _isValid(LatLng point) =>
      point.latitude.isFinite &&
      point.longitude.isFinite &&
      point.latitude >= -90 &&
      point.latitude <= 90 &&
      point.longitude >= -180 &&
      point.longitude <= 180;

  void close() => _client.close();
}
