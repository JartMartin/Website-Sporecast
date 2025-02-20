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

-- Insert data for each available commodity
DO $$
DECLARE
  v_commodity RECORD;
  v_base_price decimal;
  v_confidence_range decimal;
BEGIN
  -- Process each available commodity
  FOR v_commodity IN 
    SELECT id, symbol 
    FROM commodities 
    WHERE status = 'available'
  LOOP
    -- Set base price and confidence range based on commodity
    CASE v_commodity.symbol
      WHEN 'WHEAT' THEN 
        v_base_price := 200;
        v_confidence_range := 15;
      WHEN 'MAIZE' THEN 
        v_base_price := 180;
        v_confidence_range := 12;
      WHEN 'BARLEY' THEN 
        v_base_price := 160;
        v_confidence_range := 10;
      WHEN 'OATS' THEN 
        v_base_price := 140;
        v_confidence_range := 8;
    END CASE;

    -- Insert historical data (Dec 21, 2024 - Jan 21, 2025)
    INSERT INTO commodity_forecasts (commodity_id, date, price, is_forecast)
    SELECT 
      v_commodity.id,
      d::date,
      v_base_price + (random() * 20),
      false
    FROM generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

    -- Insert forecast data (Jan 22, 2025 - Feb 22, 2025)
    INSERT INTO commodity_forecasts (
      commodity_id, 
      date, 
      price, 
      is_forecast,
      confidence_lower,
      confidence_upper
    )
    SELECT 
      v_commodity.id,
      d::date,
      v_base_price + 20 + (random() * 25),
      true,
      v_base_price + 20 + (random() * 25) - v_confidence_range,
      v_base_price + 20 + (random() * 25) + v_confidence_range
    FROM generate_series('2025-01-22', '2025-02-22', interval '1 day') AS d;

  END LOOP;
END $$;