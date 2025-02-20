-- Drop existing table if it exists
DROP TABLE IF EXISTS wheat_forecasts_12w CASCADE;

-- Create wheat_forecasts_12w table with proper commodity relationship
CREATE TABLE wheat_forecasts_12w (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  commodity_id uuid NOT NULL REFERENCES commodities(id),
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  price_1y_ago decimal,
  price_2y_ago decimal,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_confidence_12w CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  CONSTRAINT unique_commodity_date UNIQUE(commodity_id, date)
);

-- Enable RLS
ALTER TABLE wheat_forecasts_12w ENABLE ROW LEVEL SECURITY;

-- Create RLS policy that checks portfolio access
CREATE POLICY "Wheat forecasts 12w are viewable by portfolio owners"
ON wheat_forecasts_12w FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM commodity_portfolio cp
    WHERE cp.commodity_id = wheat_forecasts_12w.commodity_id
    AND cp.user_id = auth.uid()
    AND cp.status = 'active'
  )
);

-- Create indexes for better query performance
CREATE INDEX idx_wheat_forecasts_12w_date ON wheat_forecasts_12w(date);
CREATE INDEX idx_wheat_forecasts_12w_commodity ON wheat_forecasts_12w(commodity_id);

-- Insert sample data
DO $$
DECLARE
  v_wheat_id uuid;
BEGIN
  -- Get the wheat commodity ID
  SELECT id INTO v_wheat_id
  FROM commodities
  WHERE symbol = 'WHEAT'
  LIMIT 1;

  -- Insert historical data (75% of period)
  INSERT INTO wheat_forecasts_12w (
    commodity_id,
    date,
    price,
    is_forecast,
    price_1y_ago,
    price_2y_ago
  )
  SELECT 
    v_wheat_id,
    d::date,
    200 + (random() * 20),  -- Current price between 200-220
    false,
    180 + (random() * 20),  -- Last year price between 180-200
    170 + (random() * 20)   -- Two years ago price between 170-190
  FROM generate_series(
    current_date - interval '63 days',  -- 75% of 84 days (12 weeks)
    current_date,
    interval '1 day'
  ) AS d;

  -- Insert forecast data (25% of period)
  INSERT INTO wheat_forecasts_12w (
    commodity_id,
    date,
    price,
    is_forecast,
    confidence_lower,
    confidence_upper,
    price_1y_ago,
    price_2y_ago
  )
  SELECT 
    v_wheat_id,
    d::date,
    220 + (random() * 25),  -- Forecasted price between 220-245
    true,
    205 + (random() * 15),  -- Lower bound between 205-220
    235 + (random() * 15),  -- Upper bound between 235-250
    180 + (random() * 20),  -- Last year price between 180-200
    170 + (random() * 20)   -- Two years ago price between 170-190
  FROM generate_series(
    current_date + interval '1 day',
    current_date + interval '21 days',  -- 25% of 84 days (12 weeks)
    interval '1 day'
  ) AS d;
END $$;

-- Add helpful comments
COMMENT ON TABLE wheat_forecasts_12w IS 'Contains 12-week wheat price forecasts with 75/25 historical/forecast ratio';
COMMENT ON COLUMN wheat_forecasts_12w.commodity_id IS 'References the commodity (wheat) in the commodities table';
COMMENT ON COLUMN wheat_forecasts_12w.price_1y_ago IS 'Price from same date one year ago';
COMMENT ON COLUMN wheat_forecasts_12w.price_2y_ago IS 'Price from same date two years ago';