-- Drop existing table if it exists
DROP TABLE IF EXISTS wheat_master_table CASCADE;

-- Create wheat_master_table
CREATE TABLE wheat_master_table (
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
ALTER TABLE wheat_master_table ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing data
CREATE POLICY "Wheat master data is viewable by authenticated users"
  ON wheat_master_table FOR SELECT
  TO authenticated
  USING (true);

-- Create index for better query performance
CREATE INDEX idx_wheat_master_table_date 
ON wheat_master_table(date);

-- Add helpful comments
COMMENT ON TABLE wheat_master_table IS 'Master table for wheat price data and forecasts';
COMMENT ON COLUMN wheat_master_table.is_forecast IS 'Whether this is a historical price (false) or forecast (true)';
COMMENT ON COLUMN wheat_master_table.confidence_lower IS 'Lower bound of confidence interval for forecasts';
COMMENT ON COLUMN wheat_master_table.confidence_upper IS 'Upper bound of confidence interval for forecasts';