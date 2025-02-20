-- Insert Oats V2 as a special commodity
INSERT INTO special_commodities (symbol, name, category, market_code, exchange)
VALUES ('oats-v2', 'Oats V2', 'Cereals', 'ZO', 'Chicago Mercantile Exchange (CME)')
ON CONFLICT (symbol) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  market_code = EXCLUDED.market_code,
  exchange = EXCLUDED.exchange;

-- Create oats_v2_forecasts table
CREATE TABLE oats_v2_forecasts (
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
ALTER TABLE oats_v2_forecasts ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing forecasts
CREATE POLICY "Oats V2 forecasts are viewable by authenticated users"
  ON oats_v2_forecasts FOR SELECT
  TO authenticated
  USING (true);

-- Create index for better query performance
CREATE INDEX idx_oats_v2_forecasts_date ON oats_v2_forecasts(date);

-- Insert sample data for Oats V2
INSERT INTO oats_v2_forecasts (date, price, is_forecast)
SELECT 
  d::date,
  140 + (random() * 10),
  false
FROM generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

INSERT INTO oats_v2_forecasts (
  date, 
  price, 
  is_forecast,
  confidence_lower,
  confidence_upper
)
SELECT 
  d::date,
  150 + (random() * 15),
  true,
  140 + (random() * 10) - 8,
  140 + (random() * 10) + 8
FROM generate_series('2025-01-22', '2025-02-22', interval '1 day') AS d;