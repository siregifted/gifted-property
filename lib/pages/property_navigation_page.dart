import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/navigation_route.dart';
import '../models/property.dart';
import '../repositories/osrm_route_repository.dart';
import '../services/foreground_location_source.dart';
import '../validation/navigation_policy.dart';
import '../widgets/navigation_route_map.dart';

class PropertyNavigationPage extends StatefulWidget {
  final Property property;
  final Future<NavigationRoute> Function(LatLng origin, LatLng destination)?
  routeLoader;
  final ForegroundLocationSource? locationSource;

  const PropertyNavigationPage({
    super.key,
    required this.property,
    this.routeLoader,
    this.locationSource,
  });

  @override
  State<PropertyNavigationPage> createState() => _PropertyNavigationPageState();
}

class _PropertyNavigationPageState extends State<PropertyNavigationPage> {
  final MapController _mapController = MapController();
  late final ForegroundLocationSource _locationSource;
  late final OsrmRouteRepository? _ownedRepository;
  late final Future<NavigationRoute> Function(LatLng, LatLng) _routeLoader;
  StreamSubscription<LatLng>? _locationSubscription;

  LatLng? _currentLocation;
  NavigationRoute? _route;
  int _stepIndex = 0;
  bool _loading = false;
  bool _rerouting = false;
  bool _approximateConfirmed = false;
  String? _error;
  DateTime? _lastRouteRequest;

  Property get _property => widget.property;

  LatLng get _destination => LatLng(_property.latitude!, _property.longitude!);

  bool get _isApproximate => requiresApproximateRouteAcknowledgement(_property);

  bool get _canNavigate => canPreviewPropertyRoute(_property);

  @override
  void initState() {
    super.initState();
    _locationSource = widget.locationSource ?? DeviceForegroundLocationSource();
    if (widget.routeLoader == null) {
      _ownedRepository = OsrmRouteRepository(client: http.Client());
      _routeLoader = (origin, destination) => _ownedRepository!
          .fetchDrivingRoute(origin: origin, destination: destination);
    } else {
      _ownedRepository = null;
      _routeLoader = widget.routeLoader!;
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _ownedRepository?.close();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startRoute() async {
    if (!_canNavigate ||
        _loading ||
        (_isApproximate && !_approximateConfirmed)) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final origin = await _locationSource.requestCurrentLocation();
      final route = await _routeLoader(origin, _destination);
      if (!mounted) return;
      setState(() {
        _currentLocation = origin;
        _route = route;
        _stepIndex = 0;
        _loading = false;
        _lastRouteRequest = DateTime.now();
      });
      await _locationSubscription?.cancel();
      _locationSubscription = _locationSource.watchCurrentLocation().listen(
        _onLocation,
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _error = 'Live location updates stopped. The last route is still shown; check device location settings.';
          });
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ForegroundLocationException
            ? error.message
            : error is OsrmRouteException
            ? error.message
            : 'Could not prepare this route. Check location and internet access, then try again.';
      });
    }
  }

  void _onLocation(LatLng location) {
    if (!mounted) return;
    final route = _route;
    var newStepIndex = _stepIndex;
    if (route != null) {
      while (newStepIndex < route.steps.length - 1) {
        final maneuverPoint = route.steps[newStepIndex].maneuverPoint;
        if (maneuverPoint == null ||
            _distanceMeters(location, maneuverPoint) > 35) {
          break;
        }
        newStepIndex++;
      }
    }
    setState(() {
      _currentLocation = location;
      _stepIndex = newStepIndex;
      _error = null;
    });
    unawaited(_maybeReroute(location));
  }

  Future<void> _maybeReroute(LatLng location) async {
    final route = _route;
    final lastRequest = _lastRouteRequest;
    if (route == null ||
        _rerouting ||
        lastRequest == null ||
        DateTime.now().difference(lastRequest) < const Duration(seconds: 60) ||
        _distanceToRoute(location, route.points) < 120) {
      return;
    }

    setState(() => _rerouting = true);
    _lastRouteRequest = DateTime.now();
    try {
      final updated = await _routeLoader(location, _destination);
      if (!mounted) return;
      setState(() {
        _route = updated;
        _stepIndex = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Route updated from your current location.'),
        ),
      );
    } catch (_) {
      // Keep the last valid route if a best-effort reroute request fails.
    } finally {
      _rerouting = false;
      if (mounted) setState(() {});
    }
  }

  double _distanceToRoute(LatLng location, List<LatLng> points) {
    var nearest = double.infinity;
    final stride = math.max(1, points.length ~/ 1500);
    for (var index = 0; index < points.length; index += stride) {
      nearest = math.min(nearest, _distanceMeters(location, points[index]));
      if (nearest < 70) return nearest;
    }
    return nearest;
  }

  double _distanceToNextManeuver(NavigationStep? step) {
    final location = _currentLocation;
    final point = step?.maneuverPoint;
    if (location == null || point == null) return 0;
    return _distanceMeters(location, point);
  }

  double _distanceMeters(LatLng first, LatLng second) {
    const radius = 6371000.0;
    final lat1 = first.latitude * math.pi / 180;
    final lat2 = second.latitude * math.pi / 180;
    final deltaLat = (second.latitude - first.latitude) * math.pi / 180;
    final deltaLng = (second.longitude - first.longitude) * math.pi / 180;
    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final boundedA = a.clamp(0.0, 1.0);
    return radius *
        2 *
        math.atan2(math.sqrt(boundedA), math.sqrt(1 - boundedA));
  }

  Future<void> _stopNavigation() async {
    await _locationSubscription?.cancel();
    if (!mounted) return;
    setState(() {
      _locationSubscription = null;
      _currentLocation = null;
      _route = null;
      _stepIndex = 0;
      _error = null;
      _lastRouteRequest = null;
    });
  }

  Future<void> _openMaps() async {
    final destination = '${_property.latitude},${_property.longitude}';
    final uri = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.https('maps.apple.com', '/', {
            'daddr': destination,
            'dirflg': 'd',
          })
        : Uri.https('www.google.com', '/maps/dir/', {
            'api': '1',
            'destination': destination,
            'travelmode': 'driving',
          });
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open a navigation app.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open a navigation app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canNavigate) return _buildUnavailablePage();

    final route = _route;
    final currentStep =
        route != null && _stepIndex >= 0 && _stepIndex < route.steps.length
        ? route.steps[_stepIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route to property'),
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NavigationRouteMap(
                controller: _mapController,
                destination: _destination,
                currentLocation: _currentLocation,
                route: route,
                approximateDestination: _isApproximate,
                maneuverInstruction: currentStep?.instruction,
                distanceToManeuverMeters: currentStep == null
                    ? null
                    : _distanceToNextManeuver(currentStep),
              ),
            ),
            if (route == null) _buildStartPanel() else _buildActivePanel(route),
          ],
        ),
      ),
    );
  }

  Widget _buildStartPanel() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _property.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B1F33),
              ),
            ),
            const SizedBox(height: 4),
            Text(_property.location),
            if (_isApproximate) ...[
              const SizedBox(height: 10),
              _approximateNotice(),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _approximateConfirmed,
                onChanged: (value) =>
                    setState(() => _approximateConfirmed = value ?? false),
                title: const Text(
                  'I understand this route ends at an approximate area pin.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
            const SizedBox(height: 6),
            const Text(
              'When you start, Gifted Property asks for location access while this screen is open. Your start and destination coordinates are sent to the public OSRM route service to calculate the road route. Gifted Property does not save your live location.',
              style: TextStyle(height: 1.4, color: Color(0xFF475569)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              _errorNotice(_error!),
              TextButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Try Maps instead'),
              ),
            ],
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _loading || (_isApproximate && !_approximateConfirmed)
                  ? null
                  : _startRoute,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.navigation_outlined),
              label: Text(_loading ? 'Finding route…' : 'Start route'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B1F33),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Route estimates are approximate and do not include live traffic. OSRM is a prototype service with no availability guarantee.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePanel(NavigationRoute route) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: Color(0xFF16794B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${route.formattedDistance}  ·  ${route.formattedDuration}',
                    style: const TextStyle(
                      color: Color(0xFF0B1F33),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (_rerouting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (_isApproximate) _approximateNotice(),
            Text(
              _error ?? 'Location is active only while this route screen is open. Leaving it stops updates.',
              style: const TextStyle(height: 1.4, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openMaps,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(
                      _isIos ? 'Continue in Apple Maps' : 'Continue in Maps',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1F33),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _stopNavigation,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'OSRM route • OpenStreetMap road data • no live traffic',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Widget _approximateNotice() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4D6),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE9D5A7)),
    ),
    child: const Text(
      'Approximate area pin only — this route does not identify the property entrance. Confirm the exact meeting point with the agent before travelling.',
      style: TextStyle(
        color: Color(0xFF704E00),
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
    ),
  );

  Widget _errorNotice(String message) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE5B5B5)),
    ),
    child: Text(message, style: const TextStyle(color: Color(0xFF8A2727))),
  );

  Widget _buildUnavailablePage() => Scaffold(
    appBar: AppBar(
      title: const Text('Route to property'),
      backgroundColor: const Color(0xFF0B1F33),
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined, size: 44),
            const SizedBox(height: 12),
            Text(
              _property.isSample
                  ? 'Navigation is disabled for fictional demo listings.'
                  : 'This listing has no verified or approximate route destination. Ask the agent to confirm its location.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.maybePop(context),
              child: const Text('Back to property'),
            ),
          ],
        ),
      ),
    ),
  );
}
