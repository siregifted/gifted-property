-- Restore explicit, least-privilege public read policies after catalogue view setup.
-- Public listing rows require an existing, staff-provided public area.
DROP POLICY IF EXISTS "Public can read published properties" ON public."Properties";
CREATE POLICY "Public can read published properties"
  ON public."Properties"
  FOR SELECT TO anon, authenticated
  USING (
    is_published IS TRUE
    AND NULLIF(BTRIM(public_location), '') IS NOT NULL
  );

-- Only approved media attached to published listings with a public area is readable.
DROP POLICY IF EXISTS "Public can read approved media for published properties"
  ON public."PropertyMedia";
CREATE POLICY "Public can read approved media for published properties"
  ON public."PropertyMedia"
  FOR SELECT TO anon, authenticated
  USING (
    is_approved IS TRUE
    AND EXISTS (
      SELECT 1
      FROM public."Properties" p
      WHERE p.id = "PropertyMedia".property_id
        AND p.is_published IS TRUE
        AND NULLIF(BTRIM(p.public_location), '') IS NOT NULL
    )
  );