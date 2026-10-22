# Gifted Property

Flutter buyer app for browsing published property listings, searching, viewing details and maps, contacting an agent, and requesting an inspection.

## Local development and checks

The tested toolchain for this branch is Flutter **3.47.7 stable** and Dart **3.13.5**.

```sh
flutter pub get
flutter analyze --fatal-infos
flutter test
flutter test --dart-define=USE_SAMPLE_PROPERTIES=true
```

Every app build must be bound explicitly to the intended Supabase project. Use that project's HTTPS URL and **publishable** key; for example:

```sh
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<your-project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-publishable-key> \
  --dart-define=USE_SAMPLE_PROPERTIES=true
```

The demo switch only works in Flutter **debug** mode, and is off by default. Run `flutter run -d chrome --dart-define=USE_SAMPLE_PROPERTIES=true` to preview the app offline; this explicit debug-demo mode skips Supabase initialization. Normal debug mode still requires a valid backend. Profile and release builds cannot enable fictional records and continue to require valid backend configuration. Samples include fictional prices and approximate neighbourhood pins, have no property photos, and disable enquiry/inspection actions. Never upload or describe them as genuine properties.

A release web compile smoke-test is `flutter build web --release`; it compiles without proving a live backend connection. A usable release build must include the intended `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` defines. The app now fails closed with a configuration message when either is absent. Never place a Supabase service-role key or an `sb_secret_` key in a client build. `SupabaseConfig` rejects modern secret keys and legacy JWTs carrying a `service_role` claim.

The GitHub Actions workflow runs dependency resolution, analysis, both test configurations, and a release web compile. It does not publish or deploy the app.

## Supabase data boundary

The buyer app reads only `public_properties` and `public_property_media`; it does not fall back to unrestricted `Properties` table queries if those views are unavailable. The prepared catalog migration adds `public_location` separately from the private address. A listing is visible only when published and assigned a non-empty public area. Exact addresses and coordinates are exposed only for verified rows with valid coordinate ranges; approximate rows expose an approximate pin; unverified or invalid pins and directions are withheld. Do not enter a street address in `public_location`.

The app displays only approved HTTPS `PropertyMedia` records. Cover media sorts first, followed by configured order. Supported types are `image` and `video`; a video opens its HTTPS URL in the device/browser player rather than playing inline. Both the proposed public view and client gallery cap media at eight items per property; a single catalogue media fetch is capped at 800 rows. Legacy `image_url` values are copied as **unapproved** media records and remain hidden until human review.

The catalogue query is bounded to the 100 newest published rows and search filters that loaded set client-side; home requests at most three featured rows. This avoids unbounded startup queries, but **pagination and server-side search are still needed for larger inventories**.

## Real listing data and publication

No genuine inventory is bundled in the client. Use the blank templates and checklist in `docs/` to collect and review authorized property information before publishing. Staff must verify the right to advertise, factual title/description/price/status, a safe public area label, coordinate precision and evidence, image/video rights, and media approval. Never infer a street address or verification status from a neighbourhood pin.

The database remains the source of truth for prices, publication, features, location data, and media approval. The Flutter app does not contain a property-management/admin interface. Until one is built with authenticated server-side authorization, authorized staff must use a controlled Supabase Dashboard workflow; never put a service-role key in the app.

## Buyer requests and abuse controls

Enquiries and inspection requests are insert-only from the public app and must be tied to a persisted property ID. Database policies bind each listing snapshot to a currently published canonical listing and validate field/date/time formats. Customer lead records are not readable by anonymous clients. Inspection dates use Abuja/Lagos calendar days and are limited to today through one year ahead; times are recorded in WAT (`HH:mm`).

**Public inserts do not yet have server-side rate limiting, CAPTCHA, or equivalent abuse controls.** Client-side validation and RLS are not anti-spam protections. Choose and implement an abuse-control boundary before public launch; this may require a CAPTCHA provider/secret, retention rules for any abuse telemetry, and a privacy notice. The migration must not be treated as sufficient protection against automated submissions.

## Migration status and impact

The catalog/security migration `supabase/migrations/20261022150000_public_catalog_views_and_lead_binding.sql` is a proposal and **has not been applied by this task**. It:

- adds `public_location` and `features` fields, and `NOT VALID` publication/location checks for a staged data review;
- imports legacy image URLs into `PropertyMedia` as unapproved records for staff review;
- removes API-role direct table and column grants, then grants public catalog reads only through purpose-built views;
- masks exact addresses and withholds unverified or invalid coordinates;
- reasserts column-level INSERT-only access for enquiry/inspection form fields and sequence `USAGE`;
- binds new leads to currently published canonical listings and validates fields/date/time.

Removing direct reads on `Properties`/`PropertyMedia` can break any existing admin or client code that queries those tables directly; inspect all consumers first. The migration deliberately fails if either public view already exists, so an existing view's columns, owner, grants, and consumers must be reviewed and reconciled before staging rollout. `NOT VALID` constraints protect new/updated rows but do not certify old rows: staff must backfill/review data, then validate constraints. The app will show a recoverable loading error until the views exist; it never falls back to a less-safe raw-table query.

No production schema or permissions were changed by this task. Before production use, apply the migration only after isolated/staging tests, schema/ACL/view-owner checks, data remediation, an anti-abuse plan, and explicit owner approval.

## Web deployment

`flutter build web --release` creates `build/web`. No public deployment has been performed. A production deployment requires a target host/domain, the correct backend build defines, HTTPS, SPA fallback to `index.html`, suitable cache headers, Supabase allowed origins, monitoring, and a reviewed security-header/CSP policy. The production domain and deployment target have not been supplied. The current Flutter icon artwork is a placeholder and needs brand-approved artwork.

## Android and iOS releases

Android release signing is configured to require a protected keystore and an expected certificate fingerprint; it never falls back automatically to local debug signing, and rejects the default debug filename/alias. The owner must verify the fingerprint against a trusted release-key record. See [`docs/mobile-release-signing.md`](docs/mobile-release-signing.md). No signed APK/AAB has been produced; this sandbox has not installed the required Android platform/NDK because a separate MIPS/NDK license prompt remains unresolved.

iOS compilation, signing and App Store submission require macOS/Xcode, an Apple Developer Team, and provisioning/signing assets. Those credentials were not supplied, so iOS release readiness remains unverified. No store release or deployment was performed.

See [the launch-readiness handoff](docs/launch-readiness.md) for the branch, checks actually run, limitations, and owner decisions. Reference URLs are captured in [verification sources](docs/verification-sources.md).
