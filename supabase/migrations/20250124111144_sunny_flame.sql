-- Drop existing table and related objects if they exist
DROP TABLE IF EXISTS commodity_alerts CASCADE;

-- Create commodity_alerts table
CREATE TABLE commodity_alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  type text NOT NULL CHECK (type IN ('price_above', 'price_below')),
  threshold decimal NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT commodity_alerts_unique_user_commodity_type UNIQUE (user_id, commodity_id, type)
);

-- Enable RLS
ALTER TABLE commodity_alerts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own alerts" ON commodity_alerts;
DROP POLICY IF EXISTS "Users can manage own alerts" ON commodity_alerts;

-- Create policies for commodity_alerts
CREATE POLICY "Users can view own alerts"
  ON commodity_alerts FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own alerts"
  ON commodity_alerts FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Drop existing indexes if they exist
DROP INDEX IF EXISTS idx_commodity_alerts_user;
DROP INDEX IF EXISTS idx_commodity_alerts_commodity;
DROP INDEX IF EXISTS idx_commodity_alerts_active;

-- Create indexes for better performance
CREATE INDEX idx_commodity_alerts_user ON commodity_alerts(user_id);
CREATE INDEX idx_commodity_alerts_commodity ON commodity_alerts(commodity_id);
CREATE INDEX idx_commodity_alerts_active ON commodity_alerts(is_active);

-- Add helpful comments
COMMENT ON TABLE commodity_alerts IS 'Stores price alerts for commodities';
COMMENT ON COLUMN commodity_alerts.type IS 'Type of alert: price_above or price_below';
COMMENT ON COLUMN commodity_alerts.threshold IS 'Price threshold that triggers the alert';
COMMENT ON COLUMN commodity_alerts.is_active IS 'Whether the alert is currently active';