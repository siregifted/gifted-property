# Gifted Property — Property photos and maps

This feature branch adds a property media table, location metadata, a map component, and a directions link.

## Changes
- Published listings can show multiple **approved** media URLs from `PropertyMedia`; existing `Properties.image_url` remains the fallback.
- Listing metadata now supports latitude/longitude, nearby landmarks, and a three-state location marker: `unverified`, `approximate`, or `verified`.
- Property details render an OpenStreetMap-based map only when valid coordinates exist, display attribution, show location verification status, and offer external Google Maps directions.
- No coordinates or sample properties are fabricated.

## Apply and test safely
1. Review `supabase/migrations/20261022120000_property_media_and_location_metadata.sql` in staging first. Do not run it on production until the existing policies and column types are confirmed.
2. Ensure the Flutter environment uses a Dart/Flutter SDK compatible with `pubspec.yaml`, then run:
   ```sh
   flutter pub get
   flutter analyze
   flutter test
   flutter build web
   ```
3. Add real, approved HTTPS photo URLs and verified coordinates only for properties your team has confirmed.
4. Check the map attribution and the OpenStreetMap tile usage policy before public launch. For high traffic, select a tile provider with suitable service terms.

## Data fields
`PropertyMedia`: `property_id`, `media_url`, `media_type`, `sort_order`, `is_cover`, `is_approved`, `caption`, `created_at`.

`Properties`: `latitude`, `longitude`, `location_verification_status`, `nearby_landmarks`.

## Important limits
- The Flutter model currently reads the legacy `image_url` plus approved `PropertyMedia` records. Upload/storage management UI is not included in this increment.
- Public users cannot insert, update, or delete `PropertyMedia` rows via the API. An authorized staff workflow for adding and approving media is still needed.
- The map shows only a supplied coordinate. It does not geocode a street address automatically.
- Tests/build have not been run from this connector. Do not treat the branch as production-ready until CI or a Codespace run confirms them.
