-- Drop existing policies
DROP POLICY IF EXISTS "Companies are viewable by their members" ON companies;
DROP POLICY IF EXISTS "Companies are updatable by admins" ON companies;
DROP POLICY IF EXISTS "Companies are insertable by anyone" ON companies;
DROP POLICY IF EXISTS "Invites are viewable by company admins" ON company_invites;
DROP POLICY IF EXISTS "Invites are creatable by company admins" ON company_invites;
DROP POLICY IF EXISTS "Invites are updatable by company admins" ON company_invites;

-- Create more permissive policies for companies
CREATE POLICY "Companies are insertable by anyone"
  ON companies FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Companies are viewable by their members"
  ON companies FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid()
    )
  );

CREATE POLICY "Companies are updatable by admins"
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
CREATE POLICY "Invites are viewable by company admins"
  ON company_invites FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

CREATE POLICY "Invites are creatable by company admins"
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

CREATE POLICY "Invites are updatable by company admins"
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
CREATE OR REPLACE FUNCTION handle_profile_company_update()
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
CREATE TRIGGER on_profile_company_update
  BEFORE UPDATE OF company_id ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_profile_company_update();

-- Add helpful comments
COMMENT ON POLICY "Companies are insertable by anyone" ON companies 
  IS 'Allows anyone to create a company during registration';
COMMENT ON POLICY "Companies are viewable by their members" ON companies 
  IS 'Allows company members to view their company details';
COMMENT ON POLICY "Companies are updatable by admins" ON companies 
  IS 'Allows company admins to update company details';
COMMENT ON FUNCTION handle_profile_company_update IS 'Ensures company role is properly set when company ID changes';