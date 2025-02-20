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

-- Enable RLS
ALTER TABLE commodities ENABLE ROW LEVEL SECURITY;
ALTER TABLE commodity_portfolio ENABLE ROW LEVEL SECURITY;

-- Create policies
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