# Verification sources

These official/public sources informed environment setup, map-use notes, or CI dependency pinning. They are reference links, not evidence that the app has been deployed or that a provider account has been configured.

## Android SDK setup

- [Android Studio downloads and command-line tools](https://developer.android.com/studio) — source for the official Linux command-line-tools package used during local SDK setup.
- [Android `sdkmanager` command-line documentation](https://developer.android.com/tools/sdkmanager) — package installation and SDK component/license workflow.

The user authorized acceptance of the relevant Google SDK terms for a local build check. A later, separate MIPS/NDK license prompt remains unaccepted; no Android application build was run.

## Map tiles and attribution

- [OpenStreetMap tile usage policy](https://operations.osmfoundation.org/policies/tiles/) — review this policy against projected app traffic before public launch.
- [OpenStreetMap copyright and attribution](https://www.openstreetmap.org/copyright) — linked by the map UI and used for attribution guidance.

No tile-service account, capacity guarantee, or paid tile provider has been configured.

## Pinned GitHub Actions releases

The workflow pins these release commits rather than mutable major-version tags:

- [`actions/checkout` v7.0.1](https://github.com/actions/checkout/releases/tag/v7.0.1), commit `3d3c42e5aac5ba805825da76410c181273ba90b1`.
- [`subosito/flutter-action` v2.23.0](https://github.com/subosito/flutter-action/releases/tag/v2.23.0), commit `1a449444c387b1966244ae4d4f8c696479add0b2`.
