-- Restrict public property reads to listings explicitly approved for publication.
-- Keep listing writes private to trusted/admin credentials; do not grant anon writes.
DROP POLICY IF EXISTS "Enable read access for all users" ON public."Properties";
CREATE POLICY "Public can read published properties"
  ON public."Properties"
  FOR SELECT
  TO anon, authenticated
  USING (is_published IS TRUE);

-- rls_auto_enable is an event-trigger function, not an application RPC.
-- Its DDL trigger continues to invoke it as the owning role; API roles do not need EXECUTE.
REVOKE ALL PRIVILEGES ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;
