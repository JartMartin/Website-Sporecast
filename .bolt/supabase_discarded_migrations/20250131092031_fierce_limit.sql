-- Create wheat_forecasts_12W table
CREATE TABLE wheat_forecasts_12W (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
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
  UNIQUE(date)
);

-- Enable RLS
ALTER TABLE wheat_forecasts_12W ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing forecasts
CREATE POLICY "Wheat 12W forecasts are viewable by authenticated users"
  ON wheat_forecasts_12W FOR SELECT
  TO authenticated
  USING (true);

-- Create index for better query performance
CREATE INDEX idx_wheat_forecasts_12w_date 
ON wheat_forecasts_12W(date);

-- Insert sample data for 12-week horizon
INSERT INTO wheat_forecasts_12W (date, price, is_forecast, confidence_lower, confidence_upper)
SELECT 
  d::date,
  -- Historical data (past 6 weeks)
  CASE 
    WHEN d <= current_date THEN
      200 + (random() * 20) -- Historical prices between 200-220
    ELSE
    -- Forecast data (next 6 weeks)
      220 + (random() * 25) -- Forecasted prices between 220-245
  END as price,
  d > current_date as is_forecast,
  CASE 
    WHEN d > current_date THEN
      205 + (random() * 15) -- Lower confidence bound
    ELSE NULL
  END as confidence_lower,
  CASE 
    WHEN d > current_date THEN
      235 + (random() * 15) -- Upper confidence bound
    ELSE NULL
  END as confidence_upper
FROM generate_series(
  current_date - interval '6 weeks',
  current_date + interval '6 weeks',
  interval '1 day'
) AS d;

-- Add helpful comments
COMMENT ON TABLE wheat_forecasts_12W IS 'Stores 12-week historical prices and forecasts for wheat';
COMMENT ON COLUMN wheat_forecasts_12W.is_forecast IS 'Whether this is a historical price (false) or forecast (true)';
COMMENT ON COLUMN wheat_forecasts_12W.confidence_lower IS 'Lower bound of 90% confidence interval for forecasts';
COMMENT ON COLUMN wheat_forecasts_12W.confidence_upper IS 'Upper bound of 90% confidence interval for forecasts';