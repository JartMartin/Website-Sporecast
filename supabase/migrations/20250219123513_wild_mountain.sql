-- Drop and recreate company policies to allow creation
DROP POLICY IF EXISTS "Companies are viewable by their members" ON companies;
DROP POLICY IF EXISTS "Companies are updatable by admins" ON companies;

-- More permissive policies for companies
CREATE POLICY "Companies are insertable during registration"
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

-- Add helpful comments
COMMENT ON POLICY "Companies are insertable during registration" ON companies IS 'Allows authenticated users to create companies during registration';