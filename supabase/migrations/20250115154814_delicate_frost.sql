/*
  # Dynamic Commodity Management

  1. Tables
    - commodity_settings: Stores commodity-specific settings and preferences
    - commodity_alerts: Stores user alert preferences for commodities

  2. Security
    - Enable RLS
    - Add policies for secure access
*/

-- Create commodity settings table
CREATE TABLE commodity_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  display_order integer DEFAULT 0,
  is_favorite boolean DEFAULT false,
  custom_price_alert decimal,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, commodity_id)
);

-- Create commodity alerts table
CREATE TABLE commodity_alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  alert_type text NOT NULL,
  threshold decimal NOT NULL,
  is_active boolean DEFAULT true,
  last_triggered_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_alert_type CHECK (alert_type IN ('price_above', 'price_below', 'volatility_above'))
);

-- Enable RLS
ALTER TABLE commodity_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE commodity_alerts ENABLE ROW LEVEL SECURITY;

-- Policies for commodity settings
CREATE POLICY "Users can view own commodity settings"
  ON commodity_settings FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own commodity settings"
  ON commodity_settings FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own commodity settings"
  ON commodity_settings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own commodity settings"
  ON commodity_settings FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Policies for commodity alerts
CREATE POLICY "Users can view own alerts"
  ON commodity_alerts FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own alerts"
  ON commodity_alerts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own alerts"
  ON commodity_alerts FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own alerts"
  ON commodity_alerts FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX idx_commodity_settings_user ON commodity_settings(user_id);
CREATE INDEX idx_commodity_settings_commodity ON commodity_settings(commodity_id);
CREATE INDEX idx_commodity_settings_favorite ON commodity_settings(user_id, is_favorite);
CREATE INDEX idx_commodity_alerts_user ON commodity_alerts(user_id);
CREATE INDEX idx_commodity_alerts_commodity ON commodity_alerts(commodity_id);
CREATE INDEX idx_commodity_alerts_active ON commodity_alerts(is_active);

-- Add helpful comments
COMMENT ON TABLE commodity_settings IS 'Stores user-specific settings for each commodity';
COMMENT ON TABLE commodity_alerts IS 'Stores user-defined alerts for commodity price changes';
COMMENT ON COLUMN commodity_settings.display_order IS 'Order in which commodities appear in the user''s dashboard';
COMMENT ON COLUMN commodity_settings.is_favorite IS 'Whether the commodity is marked as a favorite';
COMMENT ON COLUMN commodity_alerts.alert_type IS 'Type of alert: price_above, price_below, or volatility_above';
COMMENT ON COLUMN commodity_alerts.threshold IS 'Value that triggers the alert';