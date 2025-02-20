/*
  # Fix Profile Creation Flow

  1. Changes
    - Remove constraints that block initial profile creation
    - Simplify profile creation trigger
    - Add proper role validation for updates

  2. Security
    - Maintain RLS policies
    - Ensure proper role validation after initial creation
*/

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Create a simplified function to handle new user profile creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger for automatic profile creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Drop existing constraints that might block profile creation
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS valid_role;
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS company_not_empty;

-- Add more flexible constraints that allow initial NULL values
ALTER TABLE profiles
ADD CONSTRAINT valid_role_or_null CHECK (
  role IS NULL OR 
  role IN ('purchase_department', 'head_of_purchase', 'board_management')
);

ALTER TABLE profiles
ADD CONSTRAINT valid_company CHECK (
  company IS NULL OR 
  trim(company) <> ''
);

-- Ensure proper RLS policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- Basic policies for profile access
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Ensure insert policy exists
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Add helpful comments
COMMENT ON FUNCTION handle_new_user IS 'Creates a profile entry when a new user signs up';
COMMENT ON TRIGGER on_auth_user_created ON auth.users IS 'Automatically creates a profile for new users';