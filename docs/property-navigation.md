# Property route preview prototype

The property detail map offers **Preview route in Gifted Property** for a real listing only when its coordinates are valid and staff has marked the location `verified` or `approximate`. Fictional demo listings have no route or external-map action. Unverified locations remain hidden from directions.

## Client flow

The route page first explains the location and provider behavior. Location permission is requested only after the client taps **Start route**. The app obtains a foreground position and makes an HTTPS OSRM driving request with the client origin and listing destination. It draws the returned GeoJSON road line over the OpenStreetMap tiles and shows an approximate distance, route-time estimate and next maneuver. Location updates stay in memory while the route page is open; the app does not save location history. Leaving or stopping the route screen cancels the stream. When the client moves more than about 120 metres from the route, the app may request a new route, with at least 60 seconds between route requests. GPS updates do not each trigger an OSRM request.

The route is an estimate based on the OSRM/OpenStreetMap data and has no live traffic. It is a route preview with foreground progress and simple maneuver text, not an embedded turn-by-turn navigation SDK. The client can hand off to Google Maps on Android/web or Apple Maps on iOS for full device navigation and voice instructions.

## Location handling

The starting position and property destination are sent to `https://router.project-osrm.org` when the client starts the route and if an off-route recalculation is triggered. The app does not send that location to Gifted Property's Supabase backend and does not persist it. A client may deny permission and use the external Maps handoff instead. Location access is foreground-only; Android background-location permissions and iOS background modes are not requested.

Approximate listings must be generalized by staff before coordinates are saved. Their route destination is only that generalized area/meeting point and is not the property entrance. The app shows an amber warning and requires the client to acknowledge that before starting. The agent must confirm the real meeting point before travel. Staff verification is not inferred by the app.

## OSRM prototype dependency and attribution

The app requests one route at a time with OSRM's driving Route service, `steps=true`, full GeoJSON geometry, and no alternatives. Route points and maneuver steps are parsed locally. The client sends coordinates in the route request. The request is HTTPS and identifies the app in the native HTTP User-Agent. Browsers supply their own restricted User-Agent and the preview/production HTTPS origin as request context. Map attribution links to OpenStreetMap; route attribution links to OSRM. See the [OSRM API reference](https://project-osrm.org/docs/v5.24.0/api/) and [OSRM demo usage policy](https://github.com/Project-OSRM/osrm-backend/wiki/Api-usage-policy).

The public OSRM demo is best-effort, has no availability or quality guarantee, and may be withdrawn. Do not treat it as a production SLA or send high-volume traffic. Before public launch, select and review a suitable routing service or operate a self-hosted OSRM instance. Review its privacy policy, data retention, usage limits, availability, terms, attribution and any charges. Make the base URL configurable for that migration rather than silently relying on the public demo. Review OpenStreetMap tile usage separately; route-provider access does not change tile-server limits.

## Platform setup

Android declares coarse and fine foreground location permissions and asks at runtime. iOS has a `NSLocationWhenInUseUsageDescription`. The app does not include `ACCESS_BACKGROUND_LOCATION`, background modes or location-history storage. Browser route testing requires HTTPS and explicit browser permission.

## Verification scope

Automated tests use fixed OSRM JSON and fake location sources. They validate route parsing, instructions, eligibility, consent/approximate-location safeguards and the request contract without contacting OSRM or requesting a real device location. Real route availability and device permission dialogs must be tested on a physical device after adding genuine, staff-reviewed property inventory.
