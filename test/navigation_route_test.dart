import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gifted_property/repositories/osrm_route_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

const _osrmResponse = <String, dynamic>{
  'code': 'Ok',
  'routes': [
    {
      'distance': 1530.4,
      'duration': 512,
      'geometry': {
        'coordinates': [
          [7.4, 9.1],
          [7.41, 9.11],
          [7.42, 9.12],
        ],
        'type': 'LineString',
      },
      'legs': [
        {
          'steps': [
            {
              'name': 'Airport Road',
              'distance': 250,
              'maneuver': {
                'type': 'depart',
                'location': [7.4, 9.1],
              },
            },
            {
              'name': 'Garki Road',
              'distance': 560,
              'maneuver': {
                'type': 'turn',
                'modifier': 'right',
                'location': [7.41, 9.11],
              },
            },
            {
              'name': '',
              'distance': 0,
              'maneuver': {
                'type': 'arrive',
                'location': [7.42, 9.12],
              },
            },
          ],
        },
      ],
    },
  ],
};

void main() {
  group('OSRM route parser', () {
    test('parses GeoJSON points, totals and maneuver steps', () {
      final route = OsrmRouteRepository.parseResponse(_osrmResponse);

      expect(route.points, const [
        LatLng(9.1, 7.4),
        LatLng(9.11, 7.41),
        LatLng(9.12, 7.42),
      ]);
      expect(route.distanceMeters, 1530.4);
      expect(route.durationSeconds, 512);
      expect(route.formattedDistance, '1.5 km');
      expect(route.formattedDuration, '9 min');
      expect(route.steps.map((step) => step.instruction), [
        'Head towards Airport Road',
        'Turn right onto Garki Road',
        'Arrive at the destination',
      ]);
      expect(route.steps[1].maneuverPoint, const LatLng(9.11, 7.41));
    });

    test('rejects a no-route response with a useful message', () {
      expect(
        () => OsrmRouteRepository.parseResponse({'code': 'NoRoute'}),
        throwsA(
          isA<OsrmRouteException>().having(
            (error) => error.message,
            'message',
            contains('No drivable route'),
          ),
        ),
      );
    });

    test('rejects missing or invalid route geometry', () {
      expect(
        () => OsrmRouteRepository.parseResponse({
          'code': 'Ok',
          'routes': [
            {
              'distance': 5,
              'duration': 3,
              'geometry': {
                'coordinates': [
                  [400, 10],
                  [500, 20],
                ],
              },
              'legs': [],
            },
          ],
        }),
        throwsA(isA<OsrmRouteException>()),
      );
    });

    test(
      'makes one HTTPS driving request with steps and full geometry',
      () async {
        http.Request? captured;
        final client = MockClient((request) async {
          captured = request;
          return http.Response(jsonEncode(_osrmResponse), 200);
        });
        final repository = OsrmRouteRepository(client: client);
        try {
          final route = await repository.fetchDrivingRoute(
            origin: const LatLng(9.1, 7.4),
            destination: const LatLng(9.12, 7.42),
          );

          expect(route.points, hasLength(3));
          expect(captured!.url.scheme, 'https');
          expect(captured!.url.host, 'router.project-osrm.org');
          expect(captured!.url.path, contains('/route/v1/driving/'));
          expect(captured!.url.path, contains('7.4,9.1'));
          expect(captured!.url.queryParameters['steps'], 'true');
          expect(captured!.url.queryParameters['overview'], 'full');
          expect(captured!.url.queryParameters['geometries'], 'geojson');
          expect(captured!.headers['user-agent'], contains('GiftedProperty'));
        } finally {
          repository.close();
        }
      },
    );
  });
}
