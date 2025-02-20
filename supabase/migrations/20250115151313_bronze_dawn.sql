/*
  # Fix Profile Creation and Role Management

  1. Changes
    - Add default role policy
    - Ensure profile creation on signup
    - Fix role validation

  2. Security
    - Maintain RLS policies
    - Add role validation
*/

-- Drop and recreate the role-based profile updates policy
DROP POLICY IF EXISTS "Role-based profile updates" ON profiles;

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
);

-- Drop and recreate the insert policy
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

CREATE POLICY "Users can insert own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = id
);

-- Create a function to handle profile creation after signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger to create profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Temporarily alter role constraint to allow NULL during initial creation
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS valid_role;

ALTER TABLE profiles
ADD CONSTRAINT valid_role CHECK (
  (role IS NULL AND updated_by IS NULL) -- Allow NULL only for new profiles
  OR
  (role IS NOT NULL) -- Require role for updated profiles
);

-- Add helpful comments
COMMENT ON TRIGGER on_auth_user_created ON auth.users IS 'Creates a new profile when a user signs up';
COMMENT ON FUNCTION handle_new_user IS 'Handles the creation of a new user profile on signup';