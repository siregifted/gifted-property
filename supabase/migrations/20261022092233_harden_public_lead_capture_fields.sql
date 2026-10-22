ALTER TABLE public."Enquiries" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Inspections" ENABLE ROW LEVEL SECURITY;

REVOKE ALL PRIVILEGES
  ON TABLE public."Enquiries", public."Inspections"
  FROM PUBLIC, anon, authenticated;

GRANT INSERT (property_id, property_title, property_location, name, phone, email, message)
  ON TABLE public."Enquiries" TO anon, authenticated;
GRANT INSERT (property_id, property_title, property_location, name, phone, email, inspection_date, preferred_time, message)
  ON TABLE public."Inspections" TO anon, authenticated;

REVOKE ALL PRIVILEGES
  ON SEQUENCE public."Enquiries_id_seq", public."Inspections_id_seq"
  FROM PUBLIC, anon, authenticated;
GRANT USAGE
  ON SEQUENCE public."Enquiries_id_seq", public."Inspections_id_seq"
  TO anon, authenticated;

DROP POLICY IF EXISTS "Allow public inspection submissions"
  ON public."Inspections";
CREATE POLICY "Allow public inspection submissions"
  ON public."Inspections"
  FOR INSERT TO anon, authenticated
  WITH CHECK (
    inspection_date >= (now() AT TIME ZONE 'Africa/Lagos')::date
    AND inspection_date <= ((now() AT TIME ZONE 'Africa/Lagos')::date + INTERVAL '1 year')::date
  );
