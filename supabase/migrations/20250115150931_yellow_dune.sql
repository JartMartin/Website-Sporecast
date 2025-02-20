/*
  # Enhanced Security and Optimization

  1. Changes
    - Add enhanced RLS policies for profiles table
    - Add indexes for better query performance
    - Add audit columns for better tracking
    - Add role-based access control

  2. Security
    - Granular RLS policies based on user roles
    - Audit trail for changes
    - Enhanced data validation
*/

-- Add last_login column to profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS last_login timestamptz;

-- Add audit columns
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS updated_by uuid REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS version integer DEFAULT 1;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_company ON profiles(company);

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- Enhanced RLS Policies

-- 1. Users can view their own profile
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- 2. Users can update their own profile
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 3. Board management can view all profiles
CREATE POLICY "Board management can view all profiles"
ON profiles FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'board_management'
  )
);

-- 4. Head of purchase can view department profiles
CREATE POLICY "Head of purchase can view department profiles"
ON profiles FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.id = auth.uid()
    AND p.role = 'head_of_purchase'
    AND p.company = profiles.company
    AND profiles.role = 'purchase_department'
  )
);

-- Create a function to update the version number
CREATE OR REPLACE FUNCTION update_profile_version()
RETURNS TRIGGER AS $$
BEGIN
  NEW.version = COALESCE(OLD.version, 0) + 1;
  NEW.updated_by = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger to update version on changes
DROP TRIGGER IF EXISTS profile_version_trigger ON profiles;
CREATE TRIGGER profile_version_trigger
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_version();

-- Create a function to update last_login
CREATE OR REPLACE FUNCTION handle_user_login()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles
  SET last_login = now()
  WHERE id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger for login tracking
DROP TRIGGER IF EXISTS on_user_login ON auth.sessions;
CREATE TRIGGER on_user_login
  AFTER INSERT ON auth.sessions
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_login();

-- Add a check constraint for company name
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS company_not_empty;
ALTER TABLE profiles
ADD CONSTRAINT company_not_empty CHECK (company IS NOT NULL AND trim(company) <> '');

-- Create an index for faster user lookups
DROP INDEX IF EXISTS idx_profiles_user_lookup;
CREATE INDEX idx_profiles_user_lookup 
ON profiles(id, role, company);

-- Create a composite index for company-role queries
DROP INDEX IF EXISTS idx_profiles_company_role;
CREATE INDEX idx_profiles_company_role 
ON profiles(company, role);

-- Add helpful comment
COMMENT ON TABLE profiles IS 'User profiles with enhanced security and role-based access control';