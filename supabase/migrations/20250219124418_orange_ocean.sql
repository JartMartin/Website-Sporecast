-- First drop all dependent policies
DROP POLICY IF EXISTS "Companies are viewable by their members" ON companies;
DROP POLICY IF EXISTS "Companies are updatable by admins" ON companies;
DROP POLICY IF EXISTS "Companies are insertable during registration" ON companies;
DROP POLICY IF EXISTS "Invites are viewable by company admins" ON company_invites;
DROP POLICY IF EXISTS "Invites are creatable by company admins" ON company_invites;
DROP POLICY IF EXISTS "Invites are updatable by company admins" ON company_invites;

-- Now we can safely drop and recreate the columns
ALTER TABLE profiles
DROP COLUMN IF EXISTS company_id CASCADE,
DROP COLUMN IF EXISTS company_role CASCADE;

-- Add company-related columns to profiles
ALTER TABLE profiles
ADD COLUMN company_id uuid REFERENCES companies(id),
ADD COLUMN company_role text CHECK (company_role IN ('admin', 'user'));

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

-- Recreate policies for company_invites
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