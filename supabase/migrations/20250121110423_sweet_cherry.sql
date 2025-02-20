-- Drop commodity_forecasts table if it exists
DROP TABLE IF EXISTS commodity_forecasts CASCADE;

-- Ensure wheat_forecasts exists and has correct data
CREATE TABLE IF NOT EXISTS wheat_forecasts (
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
ALTER TABLE wheat_forecasts ENABLE ROW LEVEL SECURITY;

-- Ensure policy exists
DROP POLICY IF EXISTS "Wheat forecasts are viewable by authenticated users" ON wheat_forecasts;
CREATE POLICY "Wheat forecasts are viewable by authenticated users"
  ON wheat_forecasts FOR SELECT
  TO authenticated
  USING (true);

-- Clear existing data
TRUNCATE wheat_forecasts;

-- Insert fresh data
INSERT INTO wheat_forecasts (date, price, is_forecast)
SELECT 
  d::date,
  200 + (random() * 20),
  false
FROM generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

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