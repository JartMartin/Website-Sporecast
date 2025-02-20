-- Drop existing policies
DROP POLICY IF EXISTS "companies_insert_policy" ON companies;
DROP POLICY IF EXISTS "companies_select_policy" ON companies;
DROP POLICY IF EXISTS "companies_update_policy" ON companies;

-- Create more permissive policies for companies
CREATE POLICY "companies_insert_policy"
  ON companies FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "companies_select_policy"
  ON companies FOR SELECT
  TO public
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
  TO public
  USING (
    id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

-- Create function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Create initial profile
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
END;
$$;

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

-- Drop and recreate triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_profile_update ON profiles;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

CREATE TRIGGER on_profile_update
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_profile_update();

-- Add helpful comments
COMMENT ON FUNCTION handle_new_user IS 'Creates initial profile for new users';
COMMENT ON FUNCTION handle_profile_update IS 'Handles profile updates including company role management';