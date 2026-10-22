# Mobile release signing

## Android

The repository includes the standard Gradle wrapper (`android/gradlew`, `android/gradlew.bat`, and `android/gradle/wrapper/gradle-wrapper.jar`) matched to the configured Gradle 9.3.1 distribution. `android/local.properties`, signing credentials and keystores remain ignored.

Debug builds continue to use Flutter's normal local debug keystore. Release builds have no automatic debug-key fallback. Before `assembleRelease`, `bundleRelease` or `packageRelease`, `validateReleaseSigning` requires all of the following:

| Environment variable | Purpose |
| --- | --- |
| `GIFTED_ANDROID_KEYSTORE_PATH` | Path to the release keystore |
| `GIFTED_ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `GIFTED_ANDROID_KEY_ALIAS` | Release key alias |
| `GIFTED_ANDROID_KEY_PASSWORD` | Key password |
| `GIFTED_ANDROID_CERT_SHA256` | Expected 64-character SHA-256 fingerprint of the signing certificate |

Equivalent Gradle properties are `giftedReleaseStoreFile`, `giftedReleaseStorePassword`, `giftedReleaseKeyAlias`, `giftedReleaseKeyPassword`, and `giftedReleaseCertificateSha256`. `keytool` checks that the keystore/alias opens with the provided credentials and that the certificate fingerprint matches the separately supplied expectation. The default `debug.keystore` filename and `androiddebugkey` alias are rejected to prevent common mistakes; this is not a cryptographic detector for renamed/copied debug keystores, so verify the expected fingerprint from a trusted release-key record. The fingerprint is not a secret; store passwords are. Prefer protected secret injection, never expose secrets to pull-request jobs, and never commit the keystore or credentials. Back up the keystore securely because losing it can prevent updates to an app published with that key.

No release keystore was supplied or generated, and no signed APK/AAB was produced. Google SDK terms were accepted only after user authorization. The local SDK installer then requested a separate MIPS/NDK license that has not been accepted; no Android app build was run. Decide whether to accept that additional license before attempting a local APK check.

## iOS

A signed iOS archive requires macOS with Xcode, the owner's Apple Developer Team ID, a valid bundle identifier, signing certificate and provisioning profile (or an authorized automatic-signing workflow). These credentials were not supplied. Do not invent a Team ID or commit signing assets. This environment did not run an iOS simulator, device build or archive.

## Remaining release verification

Before store submission, the owner should supply/manage signing assets outside the repository, select final app icons, verify version/build numbers and bundle IDs, test install/upgrade flows on real Android and iOS devices, and approve store metadata. Provide reviewed privacy, terms and support URLs, and configure the final production domain/host. The app has no published policy/support URLs yet. No app-store submission or public deployment is included in this branch.
