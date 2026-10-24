/// Shared configuration for the property and route-preview raster maps.
///
/// The default source is the OSM Foundation's standard tile service. If an
/// operator selects another provider, set its URL, key (if required), and the
/// provider's required attribution at build time.
abstract final class MapTilesConfig {
  static const String urlTemplate = String.fromEnvironment(
    'MAP_TILE_URL_TEMPLATE',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  /// flutter_map uses this stable package identifier in its native User-Agent.
  static const String userAgentPackageName = 'com.siregifted.giftedproperty';

  /// Tile API keys are client-visible; only use provider keys intended for apps.
  static const String apiKey = String.fromEnvironment('MAP_TILE_API_KEY');

  static const Map<String, String> additionalOptions = <String, String>{
    if (apiKey != '') 'api_key': apiKey,
  };

  static const String attributionText = String.fromEnvironment(
    'MAP_TILE_ATTRIBUTION',
    defaultValue: '© OpenStreetMap contributors',
  );

  static const String attributionUrl = String.fromEnvironment(
    'MAP_TILE_ATTRIBUTION_URL',
    defaultValue: 'https://www.openstreetmap.org/copyright',
  );
}
