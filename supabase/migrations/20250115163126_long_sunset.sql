-- Reset and create clean slate for after-login phase
-- While preserving existing auth and profile functionality

-- Drop existing tables if they exist
DROP TABLE IF EXISTS commodity_preferences CASCADE;
DROP TABLE IF EXISTS commodity_portfolio CASCADE;
DROP TABLE IF EXISTS commodities CASCADE;

-- Create enhanced commodities table
CREATE TABLE commodities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  symbol text UNIQUE NOT NULL,
  category text NOT NULL,
  market_code text NOT NULL,
  exchange text NOT NULL,
  description text,
  price decimal DEFAULT 0,
  available boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create commodity_portfolio table for tracking user commodities
CREATE TABLE commodity_portfolio (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  added_at timestamptz DEFAULT now(),
  last_viewed_at timestamptz,
  UNIQUE(user_id, commodity_id)
);

-- Create commodity_preferences for user-specific settings
CREATE TABLE commodity_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  display_order integer DEFAULT 0,
  show_in_nav boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, commodity_id)
);

-- Enable RLS
ALTER TABLE commodities ENABLE ROW LEVEL SECURITY;
ALTER TABLE commodity_portfolio ENABLE ROW LEVEL SECURITY;
ALTER TABLE commodity_preferences ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Commodities are viewable by everyone" ON commodities;
DROP POLICY IF EXISTS "Users can view own portfolio" ON commodity_portfolio;
DROP POLICY IF EXISTS "Users can manage own portfolio" ON commodity_portfolio;
DROP POLICY IF EXISTS "Users can view own preferences" ON commodity_preferences;
DROP POLICY IF EXISTS "Users can manage own preferences" ON commodity_preferences;

-- Create new policies
CREATE POLICY "Commodities are viewable by everyone"
  ON commodities FOR SELECT
  TO authenticated
  USING (true);

-- Policies for commodity_portfolio
CREATE POLICY "Users can view own portfolio"
  ON commodity_portfolio FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own portfolio"
  ON commodity_portfolio FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policies for commodity_preferences
CREATE POLICY "Users can view own preferences"
  ON commodity_preferences FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own preferences"
  ON commodity_preferences FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX idx_commodity_portfolio_user ON commodity_portfolio(user_id);
CREATE INDEX idx_commodity_portfolio_status ON commodity_portfolio(status);
CREATE INDEX idx_commodity_preferences_user ON commodity_preferences(user_id);
CREATE INDEX idx_commodities_available ON commodities(available);

-- Insert initial commodity data
INSERT INTO commodities (name, symbol, category, market_code, exchange, available) VALUES
  ('Wheat', 'WHEAT', 'Cereals', 'ZW', 'Chicago Mercantile Exchange (CME)', true),
  ('Maize', 'MAIZE', 'Cereals', 'ZC', 'Chicago Mercantile Exchange (CME)', true),
  ('Barley', 'BARLEY', 'Cereals', 'BAR', 'Euronext', true),
  ('Oats', 'OATS', 'Cereals', 'ZO', 'Chicago Mercantile Exchange (CME)', true),
  ('Soybean', 'SOYB', 'Other', 'ZS', 'Chicago Mercantile Exchange (CME)', false),
  ('Coffee', 'COFFEE', 'Other', 'KC', 'Intercontinental Exchange (ICE)', false)
ON CONFLICT (symbol) DO UPDATE SET
  market_code = EXCLUDED.market_code,
  exchange = EXCLUDED.exchange,
  category = EXCLUDED.category,
  available = EXCLUDED.available;

-- Add helpful comments
COMMENT ON TABLE commodities IS 'Available commodities for purchase';
COMMENT ON TABLE commodity_portfolio IS 'Tracks which commodities are in each user''s portfolio';
COMMENT ON TABLE commodity_preferences IS 'User-specific display preferences for commodities';
COMMENT ON COLUMN commodity_portfolio.status IS 'Status of the commodity in user''s portfolio (active/inactive)';
COMMENT ON COLUMN commodities.available IS 'Whether the commodity is available for purchase';