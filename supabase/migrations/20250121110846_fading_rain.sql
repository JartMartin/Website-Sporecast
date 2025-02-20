-- Drop all individual commodity forecast tables
DROP TABLE IF EXISTS wheat_forecasts CASCADE;
DROP TABLE IF EXISTS wheat_volatility CASCADE;
DROP TABLE IF EXISTS maize_forecasts CASCADE;
DROP TABLE IF EXISTS maize_volatility CASCADE;
DROP TABLE IF EXISTS barley_forecasts CASCADE;
DROP TABLE IF EXISTS barley_volatility CASCADE;
DROP TABLE IF EXISTS oats_forecasts CASCADE;
DROP TABLE IF EXISTS oats_volatility CASCADE;
DROP TABLE IF EXISTS commodity_forecasts CASCADE;

-- Create a single forecasts table for all commodities
CREATE TABLE forecasts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_confidence CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  UNIQUE(commodity_id, date)
);

-- Enable RLS
ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing forecasts
CREATE POLICY "Forecasts are viewable by authenticated users"
  ON forecasts FOR SELECT
  TO authenticated
  USING (true);

-- Create index for better query performance
CREATE INDEX idx_forecasts_commodity_date 
  ON forecasts(commodity_id, date);

-- Add helpful comments
COMMENT ON TABLE forecasts IS 'Stores historical prices and price forecasts for all commodities';
COMMENT ON COLUMN forecasts.is_forecast IS 'Whether this is a historical price (false) or forecast (true)';
COMMENT ON COLUMN forecasts.confidence_lower IS 'Lower bound of 90% confidence interval for forecasts';
COMMENT ON COLUMN forecasts.confidence_upper IS 'Upper bound of 90% confidence interval for forecasts';