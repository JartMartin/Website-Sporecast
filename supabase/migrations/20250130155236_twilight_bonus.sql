-- Drop existing table if it exists
DROP TABLE IF EXISTS wheat_master_table CASCADE;

-- Create wheat_master_table with commodity_id
CREATE TABLE wheat_master_table (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  commodity_id uuid REFERENCES commodities(id) NOT NULL,
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
ALTER TABLE wheat_master_table ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing data
CREATE POLICY "Wheat master data is viewable by portfolio owners"
ON wheat_master_table FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM commodities c
    JOIN commodity_portfolio cp ON cp.commodity_id = c.id
    WHERE c.symbol = 'WHEAT'
    AND cp.user_id = auth.uid()
    AND cp.status = 'active'
  )
);

-- Create indexes for better query performance
CREATE INDEX idx_wheat_master_table_date ON wheat_master_table(date);
CREATE INDEX idx_wheat_master_table_commodity ON wheat_master_table(commodity_id);

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

  -- Insert historical data (past 30 days)
  INSERT INTO wheat_master_table (commodity_id, date, price, is_forecast)
  SELECT 
    v_wheat_id,
    d::date,
    200 + (random() * 20),
    false
  FROM generate_series(
    current_date - interval '30 days',
    current_date,
    interval '1 day'
  ) AS d;

  -- Insert forecast data (next 30 days)
  INSERT INTO wheat_master_table (
    commodity_id,
    date, 
    price, 
    is_forecast,
    confidence_lower,
    confidence_upper
  )
  SELECT 
    v_wheat_id,
    d::date,
    220 + (random() * 25),
    true,
    205 + (random() * 15),
    235 + (random() * 15)
  FROM generate_series(
    current_date + interval '1 day',
    current_date + interval '30 days',
    interval '1 day'
  ) AS d;
END $$;

-- Add helpful comments
COMMENT ON TABLE wheat_master_table IS 'Contains historical and forecasted wheat prices';
COMMENT ON COLUMN wheat_master_table.commodity_id IS 'References the commodity this forecast belongs to';