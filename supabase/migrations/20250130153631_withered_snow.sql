-- Add commodity_id to wheat_master_table
ALTER TABLE wheat_master_table
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
  UPDATE wheat_master_table
  SET commodity_id = v_wheat_id;

  -- Make commodity_id NOT NULL after populating it
  ALTER TABLE wheat_master_table
  ALTER COLUMN commodity_id SET NOT NULL;
END $$;

-- Create index for better join performance
CREATE INDEX idx_wheat_master_table_commodity_id 
ON wheat_master_table(commodity_id);

-- Update RLS policy to check portfolio access
DROP POLICY IF EXISTS "Wheat master data is viewable by authenticated users" ON wheat_master_table;

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

-- Add helpful comments
COMMENT ON COLUMN wheat_master_table.commodity_id IS 'References the commodity this forecast belongs to';
COMMENT ON INDEX idx_wheat_master_table_commodity_id IS 'Improves join performance with commodities table';