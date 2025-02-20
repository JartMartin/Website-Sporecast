-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Create improved function to handle new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    profile_exists boolean;
BEGIN
    -- Check if profile exists
    SELECT EXISTS (
        SELECT 1 FROM profiles WHERE id = NEW.id
    ) INTO profile_exists;

    -- Only create profile if it doesn't exist
    IF NOT profile_exists THEN
        INSERT INTO public.profiles (id, email)
        VALUES (NEW.id, NEW.email)
        ON CONFLICT (id) DO NOTHING;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN unique_violation THEN
        -- If we hit a race condition, just return the NEW record
        RETURN NEW;
END;
$$;

-- Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- Add helpful comment
COMMENT ON FUNCTION handle_new_user IS 'Creates a profile for new users with proper error handling';