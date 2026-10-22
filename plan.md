# Property navigation prototype plan

## Product behavior

Add an opt-in route experience from an eligible real property detail. The client taps **Preview route**, sees a privacy/location explanation, and starts foreground location only after granting permission. The app requests a driving route from OSRM using the device origin and property coordinates, draws the road route on the existing OpenStreetMap map, and updates the live-position marker and maneuver cue only while this screen is open. If the client moves more than about 120 metres off route, the app may request a new route, with a minimum 60-second interval between requests. Show route distance, estimated duration, next maneuver text, route/provider attribution, errors and a one-tap handoff to Google Maps (Android/web) or Apple Maps (iOS) for full voice turn-by-turn guidance. Do not request background location or persist location history.

Demo listings cannot be navigated. Verified properties route to their verified coordinates. Approximate listings route only to the pre-generalized area pin and keep a prominent notice that it is not the property entrance; the client must confirm the meeting point with the agent. Unverified locations remain non-navigable.

## Design

Reuse Gifted Property's existing clean property-map style: navy and white controls, amber for approximate locations, teal/green for verified destinations, OSM map tiles, restrained cards and visible attribution. Keep the map dominant, with compact route/maneuver overlays and accessible text alternatives. Location access is an explicit user action rather than an app-start request.

## Implementation and data flow

`PropertyLocationMap` exposes a route preview action for eligible records. `PropertyNavigationPage` owns the foreground-only location session, route loading, route-line map, maneuver/distance state and external maps handoff. `OsrmRouteRepository` makes a single HTTPS route request for origin and destination with route steps and GeoJSON geometry; a parsed `NavigationRoute` model isolates OSRM's response shape. Inject route loading and location access at the page boundary so tests use deterministic fixtures and never request real location or contact the network.

Use `geolocator` for on-demand permission/current position and a foreground stream; use `http` for HTTPS route requests. Declare only Android coarse/fine and iOS when-in-use permissions. Include OpenStreetMap and OSRM attribution. GPS updates update the on-screen marker and maneuver progress without per-update routing calls; route recalculation is throttled and only considered after moving off-route. No paid API, database migration or production data change is included.

## Important limitation

The selected public OSRM demo endpoint is a prototype dependency: its maintainers make no availability/quality guarantees and may withdraw access. Origin and destination coordinates are sent to that third party after the client starts navigation. Before public launch or higher traffic, replace the endpoint with a chosen, reviewed routing provider or self-hosted OSRM. This route preview is not a full embedded navigation SDK; use the external Maps handoff for voice guidance and traffic-aware navigation.

## Project structure

- `lib/widgets/property_location_map.dart`: current property map and eligible route-preview entry point.
- `lib/pages/property_navigation_page.dart`: foreground route-preview/navigation screen.
- `lib/models/navigation_route.dart`: route geometry, totals and instructions.
- `lib/repositories/osrm_route_repository.dart`: bounded HTTPS OSRM request and response parsing.
- `test/navigation_route_test.dart` and `test/property_navigation_page_test.dart`: fixture parser, privacy/state behavior and location-independent UI tests.
- `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`: when-in-use location declarations only.
- `docs/property-navigation.md`: privacy, provider limitations, attribution and launch migration requirements.
