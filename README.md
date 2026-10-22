# Gifted Property

Flutter buyer app for browsing approved property listings, searching by location or property type, viewing details, contacting an agent, and requesting an inspection.

## Local web development in GitHub Codespaces

1. Open the repository in a GitHub Codespace.
2. Ensure Flutter and the web toolchain are installed, then run:

   ```sh
   flutter doctor
   flutter pub get
   flutter analyze
   flutter test
   flutter build web
   ```

3. Start the development server on port 8080:

   ```sh
   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
   ```

4. In the Codespaces **Ports** panel, find port **8080** and choose **Open in Browser**. If it is not listed, add port 8080. Keep the terminal process running while testing.

## Supabase configuration

The Flutter app uses the project URL and a Supabase publishable key in `lib/config/supabase_config.dart`. Publishable keys are intended for client applications; never place a Supabase service-role or secret key in Flutter code.

The property repository reads only rows where `is_published = true`. Featured cards also require `is_featured = true`. The app expects the existing `Properties` table fields:

- `id`, `created_at`, `title`, `description`, `price`
- `property_type`, `location`, `bedrooms`, `bathrooms`, `status`
- `is_featured`, `is_published`, `address`, `image_url`

The connected project currently has no property rows. The app will therefore show an empty-state message until an authorized administrator adds real, verified inventory. Do not use sample prices, addresses, or photos as real listings.

### Property images

The app displays `image_url` as a network image. For production, upload approved photos to a Supabase Storage bucket and store the corresponding public URL in `image_url` only if the bucket is intentionally public. For private buckets, implement signed URLs or another controlled delivery approach. Configure image formats and size limits, and confirm that each URL loads over HTTPS. Do not grant public users permission to create or edit property rows.

## Buyer requests and database security

- Enquiries are inserted into the existing `Enquiries` table.
- Inspection requests are inserted into `Inspections`.
- Both tables have row-level security and restricted insert-column grants; customer submissions should not be readable by anonymous clients.
- The migration `20261022100000_harden_public_property_reads.sql` tightens the public listing read policy and revokes API-role execution of the `rls_auto_enable()` event-trigger function. Review and apply migrations deliberately; this migration has been added to the working branch but has not been applied to the live database.

## Admin workflow

There is currently no admin interface in the Flutter buyer app. The smallest safe interim workflow is for an authorized staff member to manage the `Properties` table and photos through Supabase Dashboard with appropriate project access. Do not expose an admin service-role key in the client app. A dedicated authenticated admin interface with server-side authorization can be added later.

## Mobile builds

Android builds require the Android SDK and accepted SDK component licences. iOS builds and simulator checks require macOS with Xcode. App Store and Play Store signing and publication are not configured in this project.
