/*
  # Simplify Profile Creation Flow

  1. Changes
    - Remove all constraints that could block initial profile creation
    - Simplify profile structure
    - Keep only essential RLS policies

  2. Security
    - Maintain basic RLS for profile access
    - Allow initial profile creation without restrictions
*/

-- Drop all existing complex constraints and policies
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Role-based profile updates" ON profiles;

-- Remove constraints that might interfere with profile creation
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS valid_role;
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS valid_role_or_null;
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS company_not_empty;
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS valid_company;

-- Create a simple trigger function for profile creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic profile creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Simple RLS policies
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Add soft constraints that don't block profile creation
ALTER TABLE profiles
ADD CONSTRAINT role_values CHECK (
  role IS NULL OR 
  role IN ('purchase_department', 'head_of_purchase', 'board_management')
);

-- Add helpful comments
COMMENT ON TABLE profiles IS 'User profiles with simplified access control';
COMMENT ON FUNCTION handle_new_user IS 'Creates a basic profile entry for new users';
COMMENT ON TRIGGER on_auth_user_created ON auth.users IS 'Automatically creates a profile when a user signs up';