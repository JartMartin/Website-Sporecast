-- Drop all existing tables and related objects
DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Drop all tables in public schema
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;

    -- Drop all views in public schema
    FOR r IN (SELECT viewname FROM pg_views WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP VIEW IF EXISTS public.' || quote_ident(r.viewname) || ' CASCADE';
    END LOOP;

    -- Drop all materialized views in public schema
    FOR r IN (SELECT matviewname FROM pg_matviews WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP MATERIALIZED VIEW IF EXISTS public.' || quote_ident(r.matviewname) || ' CASCADE';
    END LOOP;

    -- Drop all types in public schema
    FOR r IN (SELECT typname FROM pg_type WHERE typnamespace = 'public'::regnamespace AND typtype = 'e') LOOP
        EXECUTE 'DROP TYPE IF EXISTS public.' || quote_ident(r.typname) || ' CASCADE';
    END LOOP;
END $$;

-- Drop all functions in public schema
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT ns.nspname as schema, p.proname as name, oidvectortypes(p.proargtypes) as args
        FROM pg_proc p 
        INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
        WHERE ns.nspname = 'public'
    ) LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.' || quote_ident(r.name) || '(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Drop all triggers in public schema
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT DISTINCT trigger_name 
        FROM information_schema.triggers 
        WHERE trigger_schema = 'public'
    ) LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || quote_ident(r.trigger_name) || ' ON public.' || quote_ident(r.event_object_table) || ' CASCADE';
    END LOOP;
END $$;

-- Create profiles table (minimal version)
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  email text,
  full_name text,
  role text,
  company text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create basic RLS policies for profiles
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

-- Create function to handle new user creation
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

-- Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Add helpful comments
COMMENT ON TABLE profiles IS 'Stores basic user profile information';
COMMENT ON COLUMN profiles.email IS 'User email from auth.users';
COMMENT ON COLUMN profiles.role IS 'User role within the organization';
COMMENT ON COLUMN profiles.company IS 'Company name';