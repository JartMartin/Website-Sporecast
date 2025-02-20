/*
  # Profile System Enhancement

  1. Changes
    - Drops and recreates profile management triggers
    - Updates profile table structure
    - Adds email tracking
    - Implements role validation
  
  2. Security
    - Updates RLS policies if they don't exist
    - Maintains existing security model
*/

-- Drop existing triggers first
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Ensure profile table has all necessary columns
DO $$ 
BEGIN
    -- Add columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') THEN
        ALTER TABLE profiles ADD COLUMN email text;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'full_name') THEN
        ALTER TABLE profiles ADD COLUMN full_name text;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'role') THEN
        ALTER TABLE profiles ADD COLUMN role text;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'company') THEN
        ALTER TABLE profiles ADD COLUMN company text;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'created_at') THEN
        ALTER TABLE profiles ADD COLUMN created_at timestamptz DEFAULT now();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'updated_at') THEN
        ALTER TABLE profiles ADD COLUMN updated_at timestamptz DEFAULT now();
    END IF;
END $$;

-- Add role validation
DO $$ 
BEGIN
    ALTER TABLE profiles DROP CONSTRAINT IF EXISTS role_check;
    ALTER TABLE profiles ADD CONSTRAINT role_check CHECK (
        role IS NULL OR 
        role IN ('purchase_department', 'head_of_purchase', 'board_management')
    );
EXCEPTION
    WHEN others THEN null;
END $$;

-- Create function to handle new user profile creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.profiles (id, email)
    VALUES (NEW.id, NEW.email)
    ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email;
    RETURN NEW;
END;
$$;

-- Create trigger for automatic profile creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- Drop existing policies if they exist and recreate them
DO $$ 
BEGIN
    -- Drop existing policies
    DROP POLICY IF EXISTS "Profiles are viewable by owners" ON profiles;
    DROP POLICY IF EXISTS "Profiles are updateable by owners" ON profiles;
    DROP POLICY IF EXISTS "Profiles are insertable by owners" ON profiles;
    
    -- Recreate policies
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Profiles are viewable by owners'
    ) THEN
        CREATE POLICY "Profiles are viewable by owners"
            ON profiles FOR SELECT
            TO authenticated
            USING (auth.uid() = id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Profiles are updateable by owners'
    ) THEN
        CREATE POLICY "Profiles are updateable by owners"
            ON profiles FOR UPDATE
            TO authenticated
            USING (auth.uid() = id)
            WITH CHECK (auth.uid() = id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Profiles are insertable by owners'
    ) THEN
        CREATE POLICY "Profiles are insertable by owners"
            ON profiles FOR INSERT
            TO authenticated
            WITH CHECK (auth.uid() = id);
    END IF;
END $$;

-- Add helpful comments
COMMENT ON TABLE profiles IS 'Stores user profile information including email';
COMMENT ON COLUMN profiles.email IS 'User email from auth.users';
COMMENT ON COLUMN profiles.role IS 'Optional user role';
COMMENT ON COLUMN profiles.company IS 'Optional company name';