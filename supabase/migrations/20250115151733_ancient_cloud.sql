/*
  # Final Profile Creation Fix

  1. Changes
    - Remove ALL existing profile-related triggers and functions
    - Create a new, minimal trigger for profile creation
    - Remove ALL constraints that could block signup
    - Add only essential, non-blocking constraints
    - Simplify RLS policies to bare minimum

  2. Security
    - Maintain basic RLS for data protection
    - Allow initial profile creation without restrictions
    - Add role validation that doesn't block signup
*/

-- Drop ALL existing profile-related objects
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS profile_version_trigger ON profiles;
DROP TRIGGER IF EXISTS on_user_login ON auth.sessions;

DROP FUNCTION IF EXISTS handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS update_profile_version() CASCADE;
DROP FUNCTION IF EXISTS handle_user_login() CASCADE;
DROP FUNCTION IF EXISTS check_role_permission() CASCADE;
DROP FUNCTION IF EXISTS is_valid_role_change() CASCADE;

-- Remove ALL existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Role-based profile updates" ON profiles;
DROP POLICY IF EXISTS "Board management can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Head of purchase can view department profiles" ON profiles;
DROP POLICY IF EXISTS "Board management can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Head of purchase can update department profiles" ON profiles;

-- Remove ALL constraints that might block profile creation
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS valid_role;
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS valid_role_or_null;
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS company_not_empty;
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS valid_company;
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS role_values;

-- Create minimal trigger function for profile creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Create minimal trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Create minimal RLS policies
CREATE POLICY "Profiles are viewable by owners"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Profiles are updateable by owners"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Profiles are insertable by owners"
  ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Add non-blocking role validation
ALTER TABLE profiles
ADD CONSTRAINT role_check CHECK (
  role IS NULL OR 
  role IN ('purchase_department', 'head_of_purchase', 'board_management')
);

-- Add helpful comments
COMMENT ON TABLE profiles IS 'Stores user profile information';
COMMENT ON COLUMN profiles.role IS 'Optional user role, can be set after initial creation';
COMMENT ON COLUMN profiles.company IS 'Optional company name, can be set after initial creation';
COMMENT ON FUNCTION handle_new_user IS 'Creates initial profile for new users';