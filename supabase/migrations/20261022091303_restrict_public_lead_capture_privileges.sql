REVOKE ALL PRIVILEGES
  ON TABLE public."Enquiries", public."Inspections"
  FROM anon, authenticated;

GRANT INSERT
  ON TABLE public."Enquiries", public."Inspections"
  TO anon, authenticated;

REVOKE ALL PRIVILEGES
  ON SEQUENCE public."Enquiries_id_seq", public."Inspections_id_seq"
  FROM anon, authenticated;

GRANT USAGE
  ON SEQUENCE public."Enquiries_id_seq", public."Inspections_id_seq"
  TO anon, authenticated;
