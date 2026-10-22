# Gifted Property

Flutter buyer app for browsing Abuja property listings, searching by location or property type, viewing listing details, contacting an agent, and requesting an inspection. The Android and iOS runner projects are included.

## Local development

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

Android builds require the Android SDK and accepted SDK component licenses. iOS builds and simulator checks require macOS with Xcode. App Store and Play Store signing and publication are not configured in this project.

## Buyer requests

Enquiries are submitted to the existing Supabase `Enquiries` table. Inspection requests are submitted to `Inspections`. Both tables have row-level security; app clients can insert only form fields, while Supabase supplies IDs and timestamps. Client roles cannot read customer submissions. The corresponding SQL is tracked in `supabase/migrations/`.

The current property catalog is the three local entries in `lib/data/properties.dart`. The Supabase `Properties` table was empty when this work began, so replace or populate these entries with verified inventory, current pricing, and approved photos before distributing the app to customers.
