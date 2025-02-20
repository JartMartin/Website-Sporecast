/*
  # Enhance Commodity Store Integration

  1. New Tables
    - commodity_portfolio: Enhanced tracking of user portfolios with status
    - commodity_preferences: User-specific display preferences
    - commodity_metadata: Additional commodity information

  2. Security
    - Enable RLS on all new tables
    - Add policies for authenticated users
*/

-- Create commodity_portfolio table for enhanced portfolio management
CREATE TABLE IF NOT EXISTS commodity_portfolio (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  status text NOT NULL DEFAULT 'active',
  added_at timestamptz DEFAULT now(),
  last_viewed_at timestamptz,
  UNIQUE(user_id, commodity_id),
  CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'favorite'))
);

-- Create commodity_preferences for user-specific display settings
CREATE TABLE IF NOT EXISTS commodity_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  display_order integer DEFAULT 0,
  show_in_nav boolean DEFAULT true,
  custom_name text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, commodity_id)
);

-- Create commodity_metadata for extended commodity information
CREATE TABLE IF NOT EXISTS commodity_metadata (
  commodity_id uuid PRIMARY KEY REFERENCES commodities ON DELETE CASCADE,
  market_details jsonb DEFAULT '{}'::jsonb,
  trading_hours text,
  min_contract_size decimal,
  trading_currency text,
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE commodity_portfolio ENABLE ROW LEVEL SECURITY;
ALTER TABLE commodity_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE commodity_metadata ENABLE ROW LEVEL SECURITY;

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

-- Policies for commodity_metadata
CREATE POLICY "Metadata viewable by all authenticated users"
  ON commodity_metadata FOR SELECT
  TO authenticated
  USING (true);

-- Create indexes for better performance
CREATE INDEX idx_commodity_portfolio_user 
  ON commodity_portfolio(user_id);
CREATE INDEX idx_commodity_portfolio_status 
  ON commodity_portfolio(status);
CREATE INDEX idx_commodity_preferences_user 
  ON commodity_preferences(user_id);
CREATE INDEX idx_commodity_preferences_order 
  ON commodity_preferences(user_id, display_order);

-- Add helpful comments
COMMENT ON TABLE commodity_portfolio IS 'Enhanced tracking of user commodity portfolios';
COMMENT ON TABLE commodity_preferences IS 'User-specific display preferences for commodities';
COMMENT ON TABLE commodity_metadata IS 'Extended commodity information and market details';

-- Function to update last_viewed_at
CREATE OR REPLACE FUNCTION update_commodity_last_viewed()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE commodity_portfolio
  SET last_viewed_at = now()
  WHERE user_id = auth.uid()
    AND commodity_id = NEW.commodity_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for tracking commodity views
CREATE TRIGGER on_commodity_view
  AFTER INSERT OR UPDATE ON commodity_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_commodity_last_viewed();