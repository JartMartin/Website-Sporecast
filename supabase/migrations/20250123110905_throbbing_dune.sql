-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Oats V2 forecasts are viewable by authenticated users" ON oats_v2_forecasts;

-- Insert Oats V2 as a special commodity
INSERT INTO special_commodities (symbol, name, category, market_code, exchange)
VALUES ('oats-v2', 'Oats V2', 'Cereals', 'ZO', 'Chicago Mercantile Exchange (CME)')
ON CONFLICT (symbol) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  market_code = EXCLUDED.market_code,
  exchange = EXCLUDED.exchange;

-- Create policy for viewing forecasts
CREATE POLICY "Oats V2 forecasts are viewable by authenticated users"
  ON oats_v2_forecasts FOR SELECT
  TO authenticated
  USING (true);

-- Insert sample data for Oats V2
DO $$ 
BEGIN
  -- Delete existing data if any
  DELETE FROM oats_v2_forecasts;

  -- Insert historical data (Dec 21, 2024 - Jan 21, 2025)
  INSERT INTO oats_v2_forecasts (date, price, is_forecast)
  SELECT 
    d::date,
    140 + (random() * 10),
    false
  FROM generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

  -- Insert forecast data (Jan 22, 2025 - Feb 22, 2025)
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
END $$;