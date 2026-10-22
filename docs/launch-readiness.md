# Launch-readiness handoff

**Repository:** `siregifted/gifted-property`

**Branch:** `feature/launch-readiness-hardening-20261022`

**Commit:** final branch `HEAD` (short SHA supplied with the handoff)

**Status:** buyer-app hardening and release preparation implemented; production launch remains blocked on owner/environment tasks below.

## Completed in this branch

- Improved the buyer journey, responsive details/actions, search and recoverable listing load errors.
- Added typed, HTTPS-only approved property media; cover ordering, video link handling, and an eight-item gallery cap.
- Added bounded public listing/media reads (100 listing rows, up to 800 media rows/100 listings), positive persisted-ID requirements, and disabled lead actions for sample/invalid records.
- Made development demo records debug-only, conspicuously fictional, and unavailable in profile/release builds; retired the duplicate ungated fixture list.
- Made the explicit debug demo mode skip Supabase initialization so the fictional preview runs offline without credentials; normal/profile/release modes still initialize and require the configured backend.
- Added shared lead validation, Abuja/Lagos date rules, clearer submission feedback and injectable deterministic form tests.
- Added an opt-in, foreground-only OSRM route preview with a live position marker, route line, estimate, maneuver text, approximate-pin confirmation and Google/Apple Maps handoff; sample and unverified locations remain non-navigable.
- Prepared a Supabase migration for separate public area labels, filtered catalog/media views, location masking, lead-to-published-property binding, field checks and conservative ACLs. It aborts for existing catalog view names and unexpected permissive public lead-write policies.
- Added blank real-property/media intake templates, an intake checklist, setup/release documentation and pinned GitHub Actions CI.
- Added the Gradle 9.3.1 wrapper with a verified distribution SHA-256, and Android release-signing checks for supplied credentials plus a trusted expected certificate fingerprint.

## Checks actually run

- `flutter pub get` — passed.
- `dart format lib test` — passed; no pending formatting changes.
- `flutter analyze --fatal-infos` — passed with no issues.
- `flutter test` — passed (42 tests), including route parsing/policy, sample CTA isolation, approximate-location consent and permission-failure recovery.
- `flutter test --dart-define=USE_SAMPLE_PROPERTIES=true` — passed (42 tests).
- `flutter build web --release` — passed; this is a compile check, not a live Supabase or browser/device location test.
- `flutter build web --debug --dart-define=USE_SAMPLE_PROPERTIES=true` — passed and served as a credential-free local preview.
- `flutter build web --release --dart-define=USE_SAMPLE_PROPERTIES=true` — passed. The release JavaScript was checked and does not contain the demo listing markers, even when the demo flag was requested.
- Supabase migration parsed locally with `pglast` (34 statements); GitHub Actions YAML, Android manifest, iOS plist and web manifest parsed successfully. This is syntax/metadata validation only, not a database execution or hosted CI result.
- `flutter doctor -v` — confirms `/usr/lib/android-sdk` has no installed platform packages; no Android APK/AAB compile was possible. The separate NDK/MIPS license prompt remains unaccepted, as required by the owner decision below. `android/gradlew --version` launched Gradle 9.3.1 and the wrapper distribution checksum is pinned.
- `git diff --check` — passed.

An earlier test run found a stale startup-message expectation; the test was corrected and the final full suite passed.

## Not done / approval or information required

- **Supabase:** migration is proposal-only and has not been applied to staging or production. No production data, grants, policies, or project configuration were changed. Before staging, inspect schema/ACLs/role memberships/view ownership and all consumers, populate safe listing metadata, verify policy inventory and exercise anonymous reads/forms. Apply to production only after separate owner approval.
- **Public lead abuse:** direct anonymous inserts have no server-side rate limit, CAPTCHA or equivalent boundary yet. This is a public-launch blocker; choose a provider and approve its privacy/retention requirements.
- **Routing service:** the prototype sends origin/destination coordinates to the public OSRM demo, which is best-effort and has no availability guarantee. Select/review a production provider or self-host OSRM before launch; assess location privacy, traffic, usage limits and cost.
- **Real inventory:** supply staff-verified property data, advertising rights, factual prices/status, safe public labels, generalized approximate pins and approved media. No genuine inventory or imagery was invented.
- **Runtime config and web hosting:** choose the production Supabase project and build with its HTTPS URL and publishable key. No deployment host/domain, allowed-origin list, privacy/terms/support URLs, monitoring or final CSP/security-header policy was supplied. The web build is a compile artifact, not a live-backend acceptance test or deployment.
- **Android:** no APK/AAB was built. `flutter doctor -v` reports that the SDK directory has no Android platform packages. A separate NDK/MIPS license prompt from the prior setup remains unaccepted; the owner must decide whether to authorize it before installing build components. No release keystore/fingerprint was supplied.
- **iOS:** no iOS build/archive was produced; macOS/Xcode, Apple Developer Team and signing assets were not available.
- **Store/public release:** app icon artwork remains a placeholder. Device install/upgrade tests, store metadata and publication were not performed.

## Owner decisions to unblock launch

1. Approve a staging Supabase project and a separate reviewed/approved production migration rollout.
2. Select and authorize a server-side public-lead abuse-control approach.
3. Supply verified listing/media intake and approve a public tile provider appropriate for anticipated traffic.
4. Choose the production Supabase build configuration, deployment host/domain, policy URLs and monitoring.
5. Decide whether to accept the separate local NDK license; provide Android signing material and trusted release fingerprint only through protected mechanisms.
6. Provide Apple signing/team resources if an iOS release candidate is required.
