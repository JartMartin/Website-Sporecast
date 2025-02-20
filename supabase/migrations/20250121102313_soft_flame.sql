-- Drop existing commodity_forecasts table if it exists
DROP TABLE IF EXISTS commodity_forecasts;

-- Create commodity_forecasts table
CREATE TABLE commodity_forecasts (
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
ALTER TABLE commodity_forecasts ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing forecasts
CREATE POLICY "Forecasts are viewable by authenticated users"
  ON commodity_forecasts FOR SELECT
  TO authenticated
  USING (true);

-- Create index for better query performance
CREATE INDEX idx_commodity_forecasts_commodity_date 
  ON commodity_forecasts(commodity_id, date);

-- Insert historical data for Wheat (Dec 21, 2024 - Jan 21, 2025)
WITH wheat_id AS (
  SELECT id FROM commodities WHERE symbol = 'WHEAT' LIMIT 1
)
INSERT INTO commodity_forecasts (commodity_id, date, price, is_forecast)
SELECT 
  wheat_id.id,
  d::date,
  200 + (random() * 20),
  false
FROM 
  wheat_id,
  generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

-- Insert forecast data for Wheat (Jan 22, 2025 - Feb 22, 2025)
WITH wheat_id AS (
  SELECT id FROM commodities WHERE symbol = 'WHEAT' LIMIT 1
)
INSERT INTO commodity_forecasts (
  commodity_id, 
  date, 
  price, 
  is_forecast,
  confidence_lower,
  confidence_upper
)
SELECT 
  wheat_id.id,
  d::date,
  220 + (random() * 25),
  true,
  205 + (random() * 15),
  235 + (random() * 15)
FROM 
  wheat_id,
  generate_series('2025-01-22', '2025-02-22', interval '1 day') AS d;

-- Add helpful comments
COMMENT ON TABLE commodity_forecasts IS 'Stores historical prices and price forecasts for commodities';
COMMENT ON COLUMN commodity_forecasts.is_forecast IS 'Whether this is a historical price (false) or forecast (true)';
COMMENT ON COLUMN commodity_forecasts.confidence_lower IS 'Lower bound of 90% confidence interval for forecasts';
COMMENT ON COLUMN commodity_forecasts.confidence_upper IS 'Upper bound of 90% confidence interval for forecasts';