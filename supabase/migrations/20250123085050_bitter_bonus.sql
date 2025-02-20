-- Create a special commodities table for non-standard entries
CREATE TABLE special_commodities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol text UNIQUE NOT NULL,
  name text NOT NULL,
  category text NOT NULL,
  market_code text NOT NULL,
  exchange text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Insert Wheat V2 as a special commodity
INSERT INTO special_commodities (symbol, name, category, market_code, exchange)
VALUES ('wheat-v2', 'Wheat V2', 'Cereals', 'ZW', 'Chicago Mercantile Exchange (CME)');

-- Create a view to handle all portfolio entries
CREATE VIEW portfolio_view AS
SELECT 
  COALESCE(c.id, sc.id) as id,
  COALESCE(c.name, sc.name) as name,
  COALESCE(c.category, sc.category) as category,
  COALESCE(c.market_code, sc.market_code) as market_code,
  COALESCE(c.exchange, sc.exchange) as exchange,
  cp.status,
  cp.user_id,
  cp.added_at,
  cp.last_viewed_at
FROM commodity_portfolio cp
LEFT JOIN commodities c ON c.id = cp.commodity_id
LEFT JOIN special_commodities sc ON sc.id = cp.commodity_id;

-- Enable RLS on the view
ALTER VIEW portfolio_view SET (security_invoker = true);

-- Enable RLS on special_commodities
ALTER TABLE special_commodities ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing special commodities
CREATE POLICY "Special commodities are viewable by everyone"
  ON special_commodities FOR SELECT
  TO authenticated
  USING (true);

-- Create function to handle portfolio operations
CREATE OR REPLACE FUNCTION handle_portfolio_operation(
  p_user_id uuid,
  p_commodity_id uuid,
  p_operation text
) RETURNS void AS $$
BEGIN
  IF p_operation = 'unsubscribe' THEN
    -- Update status to inactive
    UPDATE commodity_portfolio
    SET 
      status = 'inactive',
      last_viewed_at = now()
    WHERE 
      user_id = p_user_id 
      AND commodity_id = p_commodity_id;
  ELSIF p_operation = 'subscribe' THEN
    -- Insert or update to active
    INSERT INTO commodity_portfolio (
      user_id,
      commodity_id,
      status,
      last_viewed_at
    )
    VALUES (
      p_user_id,
      p_commodity_id,
      'active',
      now()
    )
    ON CONFLICT (user_id, commodity_id) 
    DO UPDATE SET
      status = 'active',
      last_viewed_at = now();
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create helper function to get special commodity ID
CREATE OR REPLACE FUNCTION get_special_commodity_id(p_symbol text)
RETURNS uuid AS $$
DECLARE
  v_id uuid;
BEGIN
  SELECT id INTO v_id
  FROM special_commodities
  WHERE symbol = p_symbol;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Add helpful comments
COMMENT ON TABLE special_commodities IS 'Stores special commodity entries that are not in the main commodities table';
COMMENT ON VIEW portfolio_view IS 'Unified view of user portfolio including special commodities';
COMMENT ON FUNCTION handle_portfolio_operation IS 'Handles portfolio subscription operations';
COMMENT ON FUNCTION get_special_commodity_id IS 'Helper function to get UUID for special commodities';