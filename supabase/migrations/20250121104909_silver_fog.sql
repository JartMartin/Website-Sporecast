-- Drop existing tables and policies if they exist
DROP TABLE IF EXISTS wheat_volatility CASCADE;
DROP TABLE IF EXISTS wheat_forecasts CASCADE;

-- Create wheat_forecasts table
CREATE TABLE wheat_forecasts (
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

-- Create wheat_volatility table
CREATE TABLE wheat_volatility (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  volatility_index decimal NOT NULL CHECK (volatility_index >= 0),
  trend text CHECK (trend IN ('increasing', 'decreasing', 'stable')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(date)
);

-- Enable RLS
ALTER TABLE wheat_forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE wheat_volatility ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Wheat forecasts are viewable by authenticated users" ON wheat_forecasts;
DROP POLICY IF EXISTS "Wheat volatility data is viewable by authenticated users" ON wheat_volatility;

-- Create policies for wheat_forecasts
CREATE POLICY "Wheat forecasts are viewable by authenticated users"
  ON wheat_forecasts FOR SELECT
  TO authenticated
  USING (true);

-- Create policies for wheat_volatility
CREATE POLICY "Wheat volatility data is viewable by authenticated users"
  ON wheat_volatility FOR SELECT
  TO authenticated
  USING (true);

-- Create indexes for better query performance
CREATE INDEX idx_wheat_forecasts_date ON wheat_forecasts(date);
CREATE INDEX idx_wheat_volatility_date ON wheat_volatility(date);

-- Insert historical forecast data (Dec 21, 2024 - Jan 21, 2025)
INSERT INTO wheat_forecasts (date, price, is_forecast)
SELECT 
  d::date,
  200 + (random() * 20),
  false
FROM generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

-- Insert forecast data (Jan 22, 2025 - Feb 22, 2025)
INSERT INTO wheat_forecasts (
  date, 
  price, 
  is_forecast,
  confidence_lower,
  confidence_upper
)
SELECT 
  d::date,
  220 + (random() * 25),
  true,
  205 + (random() * 15),
  235 + (random() * 15)
FROM generate_series('2025-01-22', '2025-02-22', interval '1 day') AS d;

-- Insert volatility data (Dec 21, 2024 - Jan 21, 2025)
INSERT INTO wheat_volatility (date, volatility_index, trend)
SELECT 
  d::date,
  10 + (random() * 15), -- Volatility between 10-25
  CASE 
    WHEN random() < 0.33 THEN 'increasing'
    WHEN random() < 0.66 THEN 'decreasing'
    ELSE 'stable'
  END
FROM generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

-- Add helpful comments
COMMENT ON TABLE wheat_forecasts IS 'Stores historical prices and price forecasts for wheat';
COMMENT ON TABLE wheat_volatility IS 'Stores historical volatility data for wheat';
COMMENT ON COLUMN wheat_forecasts.is_forecast IS 'Whether this is a historical price (false) or forecast (true)';
COMMENT ON COLUMN wheat_forecasts.confidence_lower IS 'Lower bound of 90% confidence interval for forecasts';
COMMENT ON COLUMN wheat_forecasts.confidence_upper IS 'Upper bound of 90% confidence interval for forecasts';
COMMENT ON COLUMN wheat_volatility.volatility_index IS 'Volatility index value (0-100)';
COMMENT ON COLUMN wheat_volatility.trend IS 'Current volatility trend';