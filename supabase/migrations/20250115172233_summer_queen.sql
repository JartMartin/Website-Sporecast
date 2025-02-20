-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Create improved function to handle new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Only insert if profile doesn't exist
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = NEW.id) THEN
        INSERT INTO public.profiles (id, email)
        VALUES (NEW.id, NEW.email);
    END IF;
    RETURN NEW;
END;
$$;

-- Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- Add helpful comment
COMMENT ON FUNCTION handle_new_user IS 'Creates a profile for new users if one does not exist';