import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

abstract interface class ForegroundLocationSource {
  Future<LatLng> requestCurrentLocation();
  Stream<LatLng> watchCurrentLocation();
}

class ForegroundLocationException implements Exception {
  final String message;

  const ForegroundLocationException(this.message);

  @override
  String toString() => message;
}

class DeviceForegroundLocationSource implements ForegroundLocationSource {
  @override
  Future<LatLng> requestCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ForegroundLocationException(
        'Turn on your device location services to start this route.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const ForegroundLocationException(
        'Location access is blocked. Enable it for Gifted Property in your device settings.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw const ForegroundLocationException(
        'Location permission was not granted. You can enable it and try again.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      throw const ForegroundLocationException(
        'Could not get your current location. Move to an open area and try again.',
      );
    }
  }

  @override
  Stream<LatLng> watchCurrentLocation() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 12,
    ),
  ).map((position) => LatLng(position.latitude, position.longitude));
}
