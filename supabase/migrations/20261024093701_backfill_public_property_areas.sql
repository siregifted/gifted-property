-- Backfill the public-facing area from the existing non-address location field only.
-- This does not create or infer street addresses or coordinates.
UPDATE public."Properties"
SET public_location = NULLIF(BTRIM(location), '')
WHERE is_published IS TRUE
  AND NULLIF(BTRIM(public_location), '') IS NULL
  AND NULLIF(BTRIM(location), '') IS NOT NULL;

NOTIFY pgrst, 'reload schema';