# Property media and location contract

## Approved media

`PropertyMedia` is the catalogue media source. Each row has a property ID, HTTPS URL, `media_type` (`image` or `video`), `sort_order`, `is_cover`, `is_approved`, optional caption and server timestamp.

- Only approved media attached to a published listing with a public area label is exposed by `public_property_media`.
- Cover media appears first; remaining items use sort order and stable ID ordering.
- The proposed public view and Flutter model expose at most eight approved media items per listing; the client limits one media request to 800 rows (100 listings × 8 items).
- Images render in the detail gallery and listing card. A video shows a play action and opens the HTTPS URL externally; supported playback depends on the device/browser and the URL's actual media format.
- Invalid/non-HTTPS URLs and unsupported types are ignored by the client. The server-side schema also requires HTTPS and restricts media type.
- The app has no upload or approval interface. Staff must review ownership/consent, content, format, dimensions/size and link availability before setting `is_approved=true`.
- Legacy `Properties.image_url` values are copied as unapproved image records. They are not shown until staff review and approve them.

Storage bucket access, file uploads, signed URLs, image transformations, CDN configuration, moderation workflow and removal requests remain operational setup, not features implemented by this buyer app.

## Location precision

Keep the public area label in `Properties.public_location`; do not use it for a private street address. The source `location` and `address` columns are not public display labels. `public_properties` exposes:

- `public_location` as the app's `location` label;
- an exact address only when status is `verified` and latitude/longitude are both within valid ranges;
- coordinates only for `verified` or `approximate` records with a valid coordinate pair; `unverified`, null, or out-of-range coordinates return as NULL;
- nearby landmarks only with `verified`/`approximate` status and valid coordinates.

The Flutter UI also validates a coordinate pair before treating a location as verified. Approximate pins are labelled neighbourhood-only and directions use an “approximate area” action. Unverified/invalid pins are not mapped and cannot be sent to a directions service. Demo records carry `isSample=true`; their map warnings are visible and lead actions are disabled.

“Verified” is explicit staff-entered status, not inferred by the app. Staff must retain the underlying evidence and update the status only after review. For `approximate`, staff must first generalize the stored coordinates to a safe neighbourhood point; the app cannot tell whether a coordinate is truly generalized. The app does not geocode, infer property pins or verify ownership.

The buyer app also includes a foreground-only OSRM route-preview prototype. It requests device location only after the user chooses to start a route, then sends origin and destination coordinates to the public OSRM demo endpoint. Sample, unverified and invalid locations cannot be routed; approximate destinations require acknowledgement and stay labelled as area pins. OSRM demo has no service guarantee and must be replaced or self-hosted before a production launch. See [`docs/property-navigation.md`](property-navigation.md) for the privacy and provider boundary.

## Map tiles and attribution

The map uses OpenStreetMap tiles with visible attribution and a link to the copyright page. Review the [OpenStreetMap tile usage policy](https://operations.osmfoundation.org/policies/tiles/) and [copyright page](https://www.openstreetmap.org/copyright) against expected traffic before a public launch. Configure an approved provider/fallback if the standard tile service is not suitable for expected traffic. No tile-service account or paid provider has been configured.

## Catalog scale and anti-abuse

The current repository bounds catalogue reads to the 100 newest rows and featured reads to three rows, then loads no more than eight media items per listing and 800 media rows per catalogue request. Search is client-side within the 100 loaded rows; server-side search/pagination should be implemented before inventory grows beyond that bound.

Public enquiry/inspection inserts are still direct anonymous Supabase REST writes. RLS and input checks do not provide rate limiting or CAPTCHA. Add a server-side abuse-control boundary before public launch and decide privacy/retention rules before storing abuse telemetry. A CAPTCHA/verification provider and credentials have not been selected or supplied.

## Migration rollout

`supabase/migrations/20261022150000_public_catalog_views_and_lead_binding.sql` is a proposal, **not applied by this task**. It requires all preceding schema migrations through `20261022120000`, including lead column-grant hardening. It adds public area/features fields, backfills old image links as unapproved, removes API-role raw table/column grants, creates filtered views, reasserts field-only lead INSERT grants, and binds new leads to a published listing.

Before any staging application:

1. Check that `public_properties` and `public_property_media` do not already exist; the proposal intentionally fails if either name is occupied, rather than replacing an unknown view.
2. Verify source table columns, constraints, current grants/column ACLs and role memberships, sequence names, all permissive lead `INSERT`/`ALL` policies, view owners and every consumer of direct table access. The proposal aborts on unknown public lead-write policies or existing catalog-view names; reconcile them after review. The direct `Properties`/`PropertyMedia` read contract will change and may break admin/client consumers.
3. Review published records, populate a safe `public_location`, generalize approximate pins, validate verification evidence, and manually review every imported unapproved image.
4. Test in an isolated/staging Supabase project, verify the public view owner can read source tables, exercise anonymous reads and form policies, and confirm no private rows/coordinates are exposed.
5. Backfill/correct existing rows and explicitly validate the `NOT VALID` constraints when ready.
6. Add server-side rate limiting/CAPTCHA before opening public lead submission, then request separate explicit approval before any production application.

The app fails closed if the public views are absent; it will not fall back to raw tables. No production schema or permissions were changed by this task.
