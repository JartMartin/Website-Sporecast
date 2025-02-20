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

-- Insert sample data for Wheat with specific date ranges
DO $$
DECLARE
  v_wheat_id uuid;
  v_date date;
  v_base_price decimal := 200;
  v_confidence_range decimal := 15;
BEGIN
  -- Get wheat commodity ID
  SELECT id INTO v_wheat_id FROM commodities WHERE symbol = 'WHEAT' LIMIT 1;

  -- Insert historical data (Dec 21, 2024 - Jan 21, 2025)
  v_date := '2024-12-21'::date;
  WHILE v_date <= '2025-01-21'::date LOOP
    INSERT INTO commodity_forecasts (
      commodity_id,
      date,
      price,
      is_forecast,
      confidence_lower,
      confidence_upper
    ) VALUES (
      v_wheat_id,
      v_date,
      v_base_price + (random() * 20),
      false,
      NULL,
      NULL
    );
    v_date := v_date + 1;
  END LOOP;

  -- Insert forecast data (Jan 22, 2025 - Feb 22, 2025)
  WHILE v_date <= '2025-02-22'::date LOOP
    INSERT INTO commodity_forecasts (
      commodity_id,
      date,
      price,
      is_forecast,
      confidence_lower,
      confidence_upper
    ) VALUES (
      v_wheat_id,
      v_date,
      v_base_price + 20 + (random() * 25),
      true,
      v_base_price + 20 + (random() * 25) - v_confidence_range,
      v_base_price + 20 + (random() * 25) + v_confidence_range
    );
    v_date := v_date + 1;
  END LOOP;
END $$;

-- Add helpful comments
COMMENT ON TABLE commodity_forecasts IS 'Stores historical prices and price forecasts for commodities';
COMMENT ON COLUMN commodity_forecasts.is_forecast IS 'Whether this is a historical price (false) or forecast (true)';
COMMENT ON COLUMN commodity_forecasts.confidence_lower IS 'Lower bound of 90% confidence interval for forecasts';
COMMENT ON COLUMN commodity_forecasts.confidence_upper IS 'Upper bound of 90% confidence interval for forecasts';