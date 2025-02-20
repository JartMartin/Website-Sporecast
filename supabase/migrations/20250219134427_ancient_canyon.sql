-- Drop existing policies
DROP POLICY IF EXISTS "company_registration_insert_policy" ON companies;
DROP POLICY IF EXISTS "company_member_select_policy" ON companies;
DROP POLICY IF EXISTS "company_admin_update_policy" ON companies;
DROP POLICY IF EXISTS "invite_view_policy" ON company_invites;
DROP POLICY IF EXISTS "invite_create_policy" ON company_invites;
DROP POLICY IF EXISTS "invite_update_policy" ON company_invites;

-- Create more permissive policies for companies
CREATE POLICY "companies_insert_policy"
  ON companies FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "companies_select_policy"
  ON companies FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 
      FROM company_invites 
      WHERE company_id = companies.id 
      AND used_at IS NULL 
      AND expires_at > now()
    )
  );

CREATE POLICY "companies_update_policy"
  ON companies FOR UPDATE
  TO authenticated
  USING (
    id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

-- Create policies for company_invites
CREATE POLICY "invites_select_policy"
  ON company_invites FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
    OR
    (used_at IS NULL AND expires_at > now())
  );

CREATE POLICY "invites_insert_policy"
  ON company_invites FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

CREATE POLICY "invites_update_policy"
  ON company_invites FOR UPDATE
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

-- Create function to handle profile updates
CREATE OR REPLACE FUNCTION handle_profile_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Ensure company_role is set when company_id is set
  IF NEW.company_id IS NOT NULL AND NEW.company_role IS NULL THEN
    NEW.company_role := 'user';
  END IF;

  -- Clear company_role when company_id is cleared
  IF NEW.company_id IS NULL THEN
    NEW.company_role := NULL;
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger for profile updates
DROP TRIGGER IF EXISTS on_profile_update ON profiles;
CREATE TRIGGER on_profile_update
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_profile_update();

-- Add helpful comments
COMMENT ON POLICY "companies_insert_policy" ON companies 
  IS 'Allows authenticated users to create companies';
COMMENT ON POLICY "companies_select_policy" ON companies 
  IS 'Allows company members and invited users to view company details';
COMMENT ON POLICY "companies_update_policy" ON companies 
  IS 'Allows company admins to update company details';