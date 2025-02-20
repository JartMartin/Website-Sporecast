-- First drop all dependent policies
DO $$ 
BEGIN
  -- Drop policies on companies table
  DROP POLICY IF EXISTS "Companies are viewable by their members" ON companies;
  DROP POLICY IF EXISTS "Companies are updatable by admins" ON companies;
  DROP POLICY IF EXISTS "Companies are insertable during registration" ON companies;
  DROP POLICY IF EXISTS "Companies are insertable by anyone" ON companies;
  
  -- Drop policies on company_invites table
  DROP POLICY IF EXISTS "Invites are viewable by company admins" ON company_invites;
  DROP POLICY IF EXISTS "Invites are creatable by company admins" ON company_invites;
  DROP POLICY IF EXISTS "Invites are updatable by company admins" ON company_invites;
  
  -- Drop policies on profiles table that might reference company columns
  DROP POLICY IF EXISTS "Profiles are viewable by owners" ON profiles;
  DROP POLICY IF EXISTS "Profiles are updateable by owners" ON profiles;
  DROP POLICY IF EXISTS "Profiles are insertable by owners" ON profiles;
END $$;

-- Now we can safely modify the columns
ALTER TABLE profiles
DROP COLUMN IF EXISTS company_id CASCADE,
DROP COLUMN IF EXISTS company_role CASCADE;

-- Add company-related columns to profiles
ALTER TABLE profiles
ADD COLUMN company_id uuid REFERENCES companies(id),
ADD COLUMN company_role text CHECK (company_role IN ('admin', 'user'));

-- Recreate the basic profile policies
CREATE POLICY "Profiles are viewable by owners"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Profiles are updateable by owners"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Profiles are insertable by owners"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Create more permissive policies for companies
CREATE POLICY "Companies are insertable by anyone"
  ON companies FOR INSERT
  TO authenticated
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

-- Add helpful comments
COMMENT ON POLICY "Companies are insertable by anyone" ON companies 
  IS 'Allows any authenticated user to create a company';
COMMENT ON POLICY "Companies are viewable by their members" ON companies 
  IS 'Allows company members to view their company details';
COMMENT ON POLICY "Companies are updatable by admins" ON companies 
  IS 'Allows company admins to update company details';