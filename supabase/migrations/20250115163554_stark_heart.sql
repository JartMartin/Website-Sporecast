-- Drop all existing tables and related objects
DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Drop all tables in public schema except profiles
    FOR r IN (
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename != 'profiles'
    ) LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;

-- Ensure profiles table has correct structure
CREATE TABLE IF NOT EXISTS profiles (
    id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
    email text,
    full_name text,
    role text,
    company text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create basic policies
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Profiles are viewable by owners" ON profiles;
    DROP POLICY IF EXISTS "Profiles are updateable by owners" ON profiles;
    DROP POLICY IF EXISTS "Profiles are insertable by owners" ON profiles;

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
END $$;

-- Create function and trigger for new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.profiles (id, email)
    VALUES (NEW.id, NEW.email)
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- Add helpful comments
COMMENT ON TABLE profiles IS 'Stores basic user profile information';
COMMENT ON COLUMN profiles.email IS 'User email from auth.users';
COMMENT ON COLUMN profiles.role IS 'User role within the organization';
COMMENT ON COLUMN profiles.company IS 'Company name';