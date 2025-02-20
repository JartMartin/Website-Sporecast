-- Drop all existing tables and related objects
DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Drop all tables in public schema
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Create profiles table
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  email text,
  full_name text,
  role text CHECK (role IN ('purchase_department', 'head_of_purchase', 'board_management')),
  company text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create commodities table
CREATE TABLE commodities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  symbol text UNIQUE NOT NULL,
  category text NOT NULL,
  market_code text NOT NULL,
  exchange text NOT NULL,
  description text,
  status text DEFAULT 'available' CHECK (status IN ('available', 'coming-soon')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create commodity_portfolio table
CREATE TABLE commodity_portfolio (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  added_at timestamptz DEFAULT now(),
  last_viewed_at timestamptz,
  UNIQUE(user_id, commodity_id)
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE commodities ENABLE ROW LEVEL SECURITY;
ALTER TABLE commodity_portfolio ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles
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

-- Create policies for commodities and portfolio
DO $$
BEGIN
    DROP POLICY IF EXISTS "Commodities are viewable by everyone" ON commodities;
    DROP POLICY IF EXISTS "Users can view own portfolio" ON commodity_portfolio;
    DROP POLICY IF EXISTS "Users can manage own portfolio" ON commodity_portfolio;

    CREATE POLICY "Commodities are viewable by everyone"
        ON commodities FOR SELECT
        TO authenticated
        USING (true);

    CREATE POLICY "Users can view own portfolio"
        ON commodity_portfolio FOR SELECT
        TO authenticated
        USING (auth.uid() = user_id);

    CREATE POLICY "Users can manage own portfolio"
        ON commodity_portfolio FOR ALL
        TO authenticated
        USING (auth.uid() = user_id)
        WITH CHECK (auth.uid() = user_id);
END $$;

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

-- Insert initial commodity data
INSERT INTO commodities (name, symbol, category, market_code, exchange, status) VALUES
    ('Wheat', 'WHEAT', 'Cereals', 'ZW', 'Chicago Mercantile Exchange (CME)', 'available'),
    ('Maize', 'MAIZE', 'Cereals', 'ZC', 'Chicago Mercantile Exchange (CME)', 'available'),
    ('Barley', 'BARLEY', 'Cereals', 'BAR', 'Euronext', 'available'),
    ('Oats', 'OATS', 'Cereals', 'ZO', 'Chicago Mercantile Exchange (CME)', 'available'),
    ('Soybean', 'SOYB', 'Other', 'ZS', 'Chicago Mercantile Exchange (CME)', 'coming-soon'),
    ('Coffee', 'COFFEE', 'Other', 'KC', 'Intercontinental Exchange (ICE)', 'coming-soon')
ON CONFLICT (symbol) DO UPDATE SET
    market_code = EXCLUDED.market_code,
    exchange = EXCLUDED.exchange,
    category = EXCLUDED.category,
    status = EXCLUDED.status;

-- Add helpful comments
COMMENT ON TABLE profiles IS 'Stores basic user profile information';
COMMENT ON TABLE commodities IS 'Available commodities for trading';
COMMENT ON TABLE commodity_portfolio IS 'Tracks user commodity subscriptions';