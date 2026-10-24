-- Run catalogue views with caller permissions rather than view-owner permissions.
ALTER VIEW public.public_properties SET (security_invoker = true);
ALTER VIEW public.public_property_media SET (security_invoker = true);

-- Grant only the columns used by the public catalogue projections.
GRANT SELECT (
  id, created_at, title, description, price, property_type, public_location,
  bedrooms, bathrooms, status, is_featured, is_published, address, latitude,
  longitude, location_verification_status, nearby_landmarks, features
) ON TABLE public."Properties" TO anon, authenticated;

GRANT SELECT (
  id, property_id, media_url, media_type, sort_order, is_cover, is_approved, caption
) ON TABLE public."PropertyMedia" TO anon, authenticated;

DROP POLICY IF EXISTS "Public can read published properties" ON public."Properties";
CREATE POLICY "Public can read published properties"
  ON public."Properties"
  FOR SELECT TO anon, authenticated
  USING (is_published IS TRUE AND NULLIF(BTRIM(public_location), '') IS NOT NULL);

DROP POLICY IF EXISTS "Public can read approved media for published properties" ON public."PropertyMedia";
CREATE POLICY "Public can read approved media for published properties"
  ON public."PropertyMedia"
  FOR SELECT TO anon, authenticated
  USING (
    is_approved IS TRUE
    AND EXISTS (
      SELECT 1 FROM public."Properties" p
      WHERE p.id = "PropertyMedia".property_id
        AND p.is_published IS TRUE
        AND NULLIF(BTRIM(p.public_location), '') IS NOT NULL
    )
  );

NOTIFY pgrst, 'reload schema';