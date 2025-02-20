/*
  # Enhanced Role-Based Access Control

  1. Changes
    - Add policies for role-based profile management
    - Add helper functions for role validation
    - Add missing indexes for performance

  2. Security
    - Role-specific update policies
    - Hierarchical access control
*/

-- Add policy for role-based profile updates
CREATE POLICY "Role-based profile updates"
ON profiles FOR UPDATE
TO authenticated
USING (
  -- User can always update their own profile
  auth.uid() = id
  OR
  -- Board management can update any profile
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'board_management'
  )
  OR
  -- Head of purchase can update purchase department profiles in same company
  (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
      AND role = 'head_of_purchase'
    )
    AND
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.company = profiles.company
      AND profiles.role = 'purchase_department'
    )
  )
)
WITH CHECK (
  -- User can always update their own profile
  auth.uid() = id
  OR
  -- Board management can update any profile
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'board_management'
  )
  OR
  -- Head of purchase can only set purchase department role
  (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
      AND role = 'head_of_purchase'
    )
    AND profiles.role = 'purchase_department'
  )
);

-- Add policy for inserting new profiles
CREATE POLICY "Users can insert own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = id
  AND role IS NOT NULL
  AND company IS NOT NULL
);

-- Create helper function for role validation
CREATE OR REPLACE FUNCTION check_role_permission(
  acting_user_id uuid,
  target_user_id uuid,
  new_role user_role
) RETURNS boolean AS $$
DECLARE
  acting_user_role user_role;
  acting_user_company text;
BEGIN
  -- Get acting user's role and company
  SELECT role, company INTO acting_user_role, acting_user_company
  FROM profiles
  WHERE id = acting_user_id;

  -- Board management can set any role
  IF acting_user_role = 'board_management' THEN
    RETURN true;
  END IF;

  -- Head of purchase can only set purchase_department role
  IF acting_user_role = 'head_of_purchase' THEN
    RETURN new_role = 'purchase_department';
  END IF;

  -- Users can only update their own profile without changing role
  RETURN acting_user_id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add helpful comment
COMMENT ON FUNCTION check_role_permission IS 'Validates if a user has permission to set a specific role';

-- Create index for role permission checks
CREATE INDEX IF NOT EXISTS idx_profiles_role_company 
ON profiles(role, company);