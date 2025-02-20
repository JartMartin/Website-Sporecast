/*
  # Simplify Profile Management

  1. Changes
    - Simplify profile structure
    - Add basic fields
    - Enable RLS
    - Add basic policies

  2. Security
    - Enable RLS
    - Add basic owner-only policies
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Profiles are viewable by owners" ON profiles;
DROP POLICY IF EXISTS "Profiles are updateable by owners" ON profiles;
DROP POLICY IF EXISTS "Profiles are insertable by owners" ON profiles;

-- Recreate the profiles table with minimal structure
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  email text,
  role text,
  company text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create simple RLS policies
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

-- Add helpful comments
COMMENT ON TABLE profiles IS 'Stores basic user profile information';
COMMENT ON COLUMN profiles.role IS 'User role within the organization';
COMMENT ON COLUMN profiles.company IS 'Company name';