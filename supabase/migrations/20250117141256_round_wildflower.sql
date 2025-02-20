-- Create commodity_alerts table
CREATE TABLE commodity_alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  type text NOT NULL CHECK (type IN ('price_above', 'price_below')),
  threshold decimal NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  last_triggered_at timestamptz
);

-- Enable RLS
ALTER TABLE commodity_alerts ENABLE ROW LEVEL SECURITY;

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

-- Create indexes for better performance
CREATE INDEX idx_commodity_alerts_user ON commodity_alerts(user_id);
CREATE INDEX idx_commodity_alerts_commodity ON commodity_alerts(commodity_id);
CREATE INDEX idx_commodity_alerts_status ON commodity_alerts(status);

-- Add helpful comments
COMMENT ON TABLE commodity_alerts IS 'Stores price alerts for commodities';
COMMENT ON COLUMN commodity_alerts.type IS 'Type of alert: price_above or price_below';
COMMENT ON COLUMN commodity_alerts.threshold IS 'Price threshold that triggers the alert';
COMMENT ON COLUMN commodity_alerts.status IS 'Alert status: active or inactive';