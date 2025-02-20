-- Drop existing policies
DROP POLICY IF EXISTS "companies_insert_policy" ON companies;
DROP POLICY IF EXISTS "companies_select_policy" ON companies;
DROP POLICY IF EXISTS "companies_update_policy" ON companies;
DROP POLICY IF EXISTS "invites_select_policy" ON company_invites;
DROP POLICY IF EXISTS "invites_insert_policy" ON company_invites;
DROP POLICY IF EXISTS "invites_update_policy" ON company_invites;

-- Create more permissive policies for companies
CREATE POLICY "companies_insert_policy"
  ON companies FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "companies_select_policy"
  ON companies FOR SELECT
  TO public
  USING (true);

CREATE POLICY "companies_update_policy"
  ON companies FOR UPDATE
  TO public
  USING (true);

-- Create policies for company_invites
CREATE POLICY "invites_select_policy"
  ON company_invites FOR SELECT
  TO public
  USING (true);

CREATE POLICY "invites_insert_policy"
  ON company_invites FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "invites_update_policy"
  ON company_invites FOR UPDATE
  TO public
  USING (true);

-- Create function to handle profile updates
CREATE OR REPLACE FUNCTION handle_profile_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Set updated_at timestamp
  NEW.updated_at := now();
  
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
COMMENT ON POLICY "companies_insert_policy" ON companies IS 'Allows anyone to create a company';
COMMENT ON POLICY "companies_select_policy" ON companies IS 'Allows anyone to view companies';
COMMENT ON POLICY "companies_update_policy" ON companies IS 'Allows anyone to update companies';
COMMENT ON FUNCTION handle_profile_update IS 'Handles profile updates including company role management';