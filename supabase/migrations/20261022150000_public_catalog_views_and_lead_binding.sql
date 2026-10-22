-- Gifted Property launch-readiness hardening.
-- This migration is prepared for review only; do not apply to production without approval.
-- Prerequisites: all earlier migrations through 20261022120000, including
-- 20261022090955_mobile_lead_capture.sql and
-- 20261022092233_harden_public_lead_capture_fields.sql.

-- Do not silently replace a view whose owner, projection, grants or consumers
-- have not been reviewed. Reconcile any existing view manually in staging.
DO $$
BEGIN
  IF to_regclass('public.public_properties') IS NOT NULL THEN
    RAISE EXCEPTION 'public.public_properties already exists; inspect and reconcile it before this migration';
  END IF;
  IF to_regclass('public.public_property_media') IS NOT NULL THEN
    RAISE EXCEPTION 'public.public_property_media already exists; inspect and reconcile it before this migration';
  END IF;
END
$$;

-- PostgreSQL OR-combines permissive policies. Stop before any DDL if a custom
-- public INSERT/ALL policy could bypass the canonical-property lead checks.
DO $$
DECLARE
  unexpected_policy record;
BEGIN
  SELECT schemaname, tablename, policyname
    INTO unexpected_policy
  FROM pg_policies
  WHERE schemaname = 'public'
    AND tablename IN ('Enquiries', 'Inspections')
    AND cmd IN ('INSERT', 'ALL')
    AND permissive = 'PERMISSIVE'
    AND roles && ARRAY['public', 'anon', 'authenticated']::name[]
    AND NOT (
      (tablename = 'Enquiries' AND policyname = 'Allow public enquiry submissions')
      OR (tablename = 'Inspections' AND policyname = 'Allow public inspection submissions')
    )
  LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION
      'Unexpected permissive lead write policy %.%.%; review/remove it before this migration',
      unexpected_policy.schemaname,
      unexpected_policy.tablename,
      unexpected_policy.policyname;
  END IF;
END
$$;

ALTER TABLE public."Properties"
  ADD COLUMN IF NOT EXISTS public_location text,
  ADD COLUMN IF NOT EXISTS features text[] NOT NULL DEFAULT '{}';

-- Existing published rows without an explicitly approved public area stay hidden
-- until staff populate public_location. NOT VALID allows safe rollout assessment
-- before existing inventory is corrected; new/updated rows must satisfy the rule.
ALTER TABLE public."Properties"
  DROP CONSTRAINT IF EXISTS properties_published_requires_public_location;
ALTER TABLE public."Properties"
  ADD CONSTRAINT properties_published_requires_public_location
  CHECK (
    is_published IS NOT TRUE
    OR NULLIF(BTRIM(public_location), '') IS NOT NULL
  ) NOT VALID;

-- Keep new verified locations within valid coordinate ranges. Existing rows must
-- be reviewed before the constraint is validated; invalid coordinates stay hidden
-- by the public view below in the meantime.
ALTER TABLE public."Properties"
  DROP CONSTRAINT IF EXISTS properties_verified_requires_coordinates;
ALTER TABLE public."Properties"
  ADD CONSTRAINT properties_verified_requires_coordinates
  CHECK (
    location_verification_status <> 'verified'
    OR (
      latitude IS NOT NULL
      AND longitude IS NOT NULL
      AND latitude BETWEEN -90 AND 90
      AND longitude BETWEEN -180 AND 180
    )
  ) NOT VALID;

CREATE INDEX IF NOT EXISTS properties_public_catalog_order_idx
  ON public."Properties" (is_published, is_featured, created_at DESC);
CREATE INDEX IF NOT EXISTS property_media_approved_catalog_order_idx
  ON public."PropertyMedia" (property_id, is_cover DESC, sort_order, id)
  WHERE is_approved IS TRUE;

-- Preserve legacy image URLs for a staff review, but never treat them as approved.
-- The public media view below deliberately excludes every unapproved record.
INSERT INTO public."PropertyMedia" (
  property_id,
  media_url,
  media_type,
  sort_order,
  is_cover,
  is_approved,
  caption
)
SELECT
  p.id,
  BTRIM(p.image_url),
  'image',
  0,
  FALSE,
  FALSE,
  'Imported from legacy image_url; review and approve before publication.'
FROM public."Properties" AS p
WHERE NULLIF(BTRIM(p.image_url), '') IS NOT NULL
  AND p.image_url ~* '^https://'
  AND NOT EXISTS (
    SELECT 1
    FROM public."PropertyMedia" AS existing_media
    WHERE existing_media.property_id = p.id
      AND existing_media.media_url = BTRIM(p.image_url)
  );

ALTER TABLE public."Properties" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."PropertyMedia" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Enquiries" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Inspections" ENABLE ROW LEVEL SECURITY;

-- Public clients read only the purpose-built views below, never raw catalog tables.
DROP POLICY IF EXISTS "Enable read access for all users"
  ON public."Properties";
DROP POLICY IF EXISTS "Public can read published properties"
  ON public."Properties";
DROP POLICY IF EXISTS "Public can read approved media for published properties"
  ON public."PropertyMedia";

REVOKE ALL PRIVILEGES
  ON TABLE public."Properties", public."PropertyMedia"
  FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES
  ON TABLE public."Enquiries", public."Inspections"
  FROM PUBLIC, anon, authenticated;

-- PostgreSQL keeps column grants separately from table grants. Remove every
-- existing API-role column grant, including grants on columns not known here.
DO $$
DECLARE
  column_grant record;
  grantee_sql text;
BEGIN
  FOR column_grant IN
    SELECT table_schema, table_name, column_name, grantee, privilege_type
    FROM information_schema.column_privileges
    WHERE table_schema = 'public'
      AND table_name IN ('Properties', 'PropertyMedia', 'Enquiries', 'Inspections')
      AND grantee IN ('PUBLIC', 'anon', 'authenticated')
  LOOP
    grantee_sql := CASE
      WHEN column_grant.grantee = 'PUBLIC' THEN 'PUBLIC'
      ELSE quote_ident(column_grant.grantee)
    END;
    EXECUTE format(
      'REVOKE %s (%I) ON TABLE %I.%I FROM %s',
      column_grant.privilege_type,
      column_grant.column_name,
      column_grant.table_schema,
      column_grant.table_name,
      grantee_sql
    );
  END LOOP;
END
$$;

-- Security-barrier views run with their trusted owner privileges. Their explicit
-- projections and filters are the public boundary; inspect view ownership and
-- underlying table privileges in staging before rollout.
CREATE VIEW public.public_properties
WITH (security_barrier = true)
AS
SELECT
  p.id,
  p.created_at,
  p.title,
  p.description,
  p.price,
  p.property_type,
  p.public_location AS location,
  p.bedrooms,
  p.bathrooms,
  p.status,
  p.is_featured,
  p.is_published,
  CASE
    WHEN p.location_verification_status = 'verified'
      AND p.latitude BETWEEN -90 AND 90
      AND p.longitude BETWEEN -180 AND 180
    THEN NULLIF(BTRIM(p.address), '')
    ELSE NULL
  END AS address,
  CASE
    WHEN p.location_verification_status IN ('verified', 'approximate')
      AND p.latitude BETWEEN -90 AND 90
      AND p.longitude BETWEEN -180 AND 180
    THEN p.latitude
    ELSE NULL
  END AS latitude,
  CASE
    WHEN p.location_verification_status IN ('verified', 'approximate')
      AND p.latitude BETWEEN -90 AND 90
      AND p.longitude BETWEEN -180 AND 180
    THEN p.longitude
    ELSE NULL
  END AS longitude,
  p.location_verification_status,
  CASE
    WHEN p.location_verification_status IN ('verified', 'approximate')
      AND p.latitude BETWEEN -90 AND 90
      AND p.longitude BETWEEN -180 AND 180
    THEN p.nearby_landmarks
    ELSE ARRAY[]::text[]
  END AS nearby_landmarks,
  p.features
FROM public."Properties" AS p
WHERE p.is_published IS TRUE
  AND NULLIF(BTRIM(p.public_location), '') IS NOT NULL;

CREATE VIEW public.public_property_media
WITH (security_barrier = true)
AS
SELECT
  approved_media.id,
  approved_media.property_id,
  approved_media.media_url,
  approved_media.media_type,
  approved_media.sort_order,
  approved_media.is_cover,
  approved_media.is_approved,
  approved_media.caption
FROM (
  SELECT
    m.id,
    m.property_id,
    m.media_url,
    m.media_type,
    m.sort_order,
    m.is_cover,
    m.is_approved,
    m.caption,
    ROW_NUMBER() OVER (
      PARTITION BY m.property_id
      ORDER BY m.is_cover DESC, m.sort_order, m.id
    ) AS media_rank
  FROM public."PropertyMedia" AS m
  JOIN public."Properties" AS p ON p.id = m.property_id
  WHERE m.is_approved IS TRUE
    AND p.is_published IS TRUE
    AND NULLIF(BTRIM(p.public_location), '') IS NOT NULL
) AS approved_media
WHERE approved_media.media_rank <= 8;

REVOKE ALL PRIVILEGES
  ON TABLE public.public_properties, public.public_property_media
  FROM PUBLIC, anon, authenticated;
GRANT SELECT
  ON TABLE public.public_properties, public.public_property_media
  TO anon, authenticated;

-- Reassert INSERT-only, form-column grants even if an installation missed an
-- earlier hardening migration. Do not grant SELECT/UPDATE/DELETE on lead records.
-- These public inserts still need a server-side rate-limit/abuse-control boundary
-- before launch; direct client calls can otherwise automate valid-looking leads.
GRANT INSERT (
  property_id, property_title, property_location, name, phone, email, message
)
  ON TABLE public."Enquiries" TO anon, authenticated;
GRANT INSERT (
  property_id, property_title, property_location, name, phone, email,
  inspection_date, preferred_time, message
)
  ON TABLE public."Inspections" TO anon, authenticated;
REVOKE ALL PRIVILEGES
  ON SEQUENCE public."Enquiries_id_seq", public."Inspections_id_seq"
  FROM PUBLIC, anon, authenticated;
GRANT USAGE
  ON SEQUENCE public."Enquiries_id_seq", public."Inspections_id_seq"
  TO anon, authenticated;

-- Public lead rows must be tied to a currently published, canonical listing.
DROP POLICY IF EXISTS "Allow public enquiry submissions"
  ON public."Enquiries";
CREATE POLICY "Allow public enquiry submissions"
  ON public."Enquiries"
  FOR INSERT TO anon, authenticated
  WITH CHECK (
    property_id IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM public.public_properties AS p
      WHERE p.id = "Enquiries".property_id
        AND p.title = "Enquiries".property_title
        AND p.location = "Enquiries".property_location
    )
    AND char_length(BTRIM(name)) BETWEEN 2 AND 120
    AND char_length(BTRIM(phone)) BETWEEN 7 AND 32
    AND char_length(regexp_replace(BTRIM(phone), '[^0-9]', '', 'g')) BETWEEN 7 AND 20
    AND BTRIM(phone) ~ '^[0-9+(). -]+$'
    AND char_length(BTRIM(email)) BETWEEN 3 AND 254
    AND email ~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$'
    AND char_length(BTRIM(property_title)) BETWEEN 1 AND 200
    AND char_length(BTRIM(property_location)) BETWEEN 1 AND 200
    AND char_length(BTRIM(message)) BETWEEN 1 AND 4000
  );

DROP POLICY IF EXISTS "Allow public inspection submissions"
  ON public."Inspections";
CREATE POLICY "Allow public inspection submissions"
  ON public."Inspections"
  FOR INSERT TO anon, authenticated
  WITH CHECK (
    property_id IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM public.public_properties AS p
      WHERE p.id = "Inspections".property_id
        AND p.title = "Inspections".property_title
        AND p.location = "Inspections".property_location
    )
    AND inspection_date >= (now() AT TIME ZONE 'Africa/Lagos')::date
    AND inspection_date <= ((now() AT TIME ZONE 'Africa/Lagos')::date + INTERVAL '1 year')::date
    AND preferred_time ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'
    AND char_length(BTRIM(name)) BETWEEN 2 AND 120
    AND char_length(BTRIM(phone)) BETWEEN 7 AND 32
    AND char_length(regexp_replace(BTRIM(phone), '[^0-9]', '', 'g')) BETWEEN 7 AND 20
    AND BTRIM(phone) ~ '^[0-9+(). -]+$'
    AND char_length(BTRIM(email)) BETWEEN 3 AND 254
    AND email ~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$'
    AND char_length(BTRIM(property_title)) BETWEEN 1 AND 200
    AND char_length(BTRIM(property_location)) BETWEEN 1 AND 200
    AND char_length(BTRIM(message)) BETWEEN 1 AND 4000
  );

-- This is a database event-trigger function, not a client RPC.
REVOKE ALL PRIVILEGES
  ON FUNCTION public.rls_auto_enable()
  FROM PUBLIC, anon, authenticated;

NOTIFY pgrst, 'reload schema';
