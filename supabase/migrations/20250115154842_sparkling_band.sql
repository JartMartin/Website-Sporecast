/*
  # Fix Commodity Management System

  1. Changes
    - Add market_code and exchange columns to commodities
    - Create user_portfolio table for tracking user's commodities
    - Add proper RLS policies
    - Preserve existing data

  2. Security
    - Enable RLS on new tables
    - Add policies for authenticated users
*/

-- Add new columns to commodities if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'commodities' AND column_name = 'market_code') THEN
    ALTER TABLE commodities 
      ADD COLUMN market_code text,
      ADD COLUMN exchange text,
      ADD COLUMN description text;
  END IF;
END $$;

-- Create user_portfolio table
CREATE TABLE IF NOT EXISTS user_portfolio (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  added_at timestamptz DEFAULT now(),
  is_active boolean DEFAULT true,
  display_order integer DEFAULT 0,
  UNIQUE(user_id, commodity_id)
);

-- Enable RLS on user_portfolio
ALTER TABLE user_portfolio ENABLE ROW LEVEL SECURITY;

-- Create policies for user_portfolio
CREATE POLICY "Users can view own portfolio"
  ON user_portfolio FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can add to portfolio"
  ON user_portfolio FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own portfolio"
  ON user_portfolio FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can remove from portfolio"
  ON user_portfolio FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Update commodity data with market codes and exchanges
UPDATE commodities 
SET 
  market_code = CASE symbol
    WHEN 'WHEAT' THEN 'ZW'
    WHEN 'MAIZE' THEN 'ZC'
    WHEN 'BARLEY' THEN 'BAR'
    WHEN 'OATS' THEN 'ZO'
    WHEN 'SOYB' THEN 'ZS'
    WHEN 'COFFEE' THEN 'KC'
  END,
  exchange = CASE 
    WHEN symbol IN ('WHEAT', 'MAIZE', 'OATS', 'SOYB') THEN 'Chicago Mercantile Exchange (CME)'
    WHEN symbol = 'BARLEY' THEN 'Euronext'
    WHEN symbol = 'COFFEE' THEN 'Intercontinental Exchange (ICE)'
  END,
  description = name || ' commodity tracking and forecasting'
WHERE market_code IS NULL;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_portfolio_user 
  ON user_portfolio(user_id);
CREATE INDEX IF NOT EXISTS idx_user_portfolio_commodity 
  ON user_portfolio(commodity_id);
CREATE INDEX IF NOT EXISTS idx_user_portfolio_active 
  ON user_portfolio(is_active);

-- Add helpful comments
COMMENT ON TABLE user_portfolio IS 'Tracks which commodities are in each user''s portfolio';
COMMENT ON COLUMN user_portfolio.is_active IS 'Whether the commodity is currently active in the user''s portfolio';
COMMENT ON COLUMN user_portfolio.display_order IS 'Order in which commodities appear in the user''s dashboard';