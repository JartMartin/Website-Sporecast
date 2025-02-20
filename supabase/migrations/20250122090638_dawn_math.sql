-- Add commodity_id column to wheat_forecasts
ALTER TABLE wheat_forecasts
ADD COLUMN commodity_id uuid REFERENCES commodities(id);

-- Get the wheat commodity ID
DO $$
DECLARE
  v_wheat_id uuid;
BEGIN
  -- Get the ID for wheat
  SELECT id INTO v_wheat_id
  FROM commodities
  WHERE symbol = 'WHEAT'
  LIMIT 1;

  -- Update all existing records with the wheat commodity ID
  UPDATE wheat_forecasts
  SET commodity_id = v_wheat_id;

  -- Make commodity_id NOT NULL after populating it
  ALTER TABLE wheat_forecasts
  ALTER COLUMN commodity_id SET NOT NULL;
END $$;

-- Add index for better join performance
CREATE INDEX idx_wheat_forecasts_commodity_id 
ON wheat_forecasts(commodity_id);

-- Add helpful comments
COMMENT ON COLUMN wheat_forecasts.commodity_id IS 'References the commodity this forecast belongs to';