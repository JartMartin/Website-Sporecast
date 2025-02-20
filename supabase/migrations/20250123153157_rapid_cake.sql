-- Add user_id index to commodity_portfolio for faster lookups
CREATE INDEX IF NOT EXISTS idx_commodity_portfolio_user_commodity 
ON commodity_portfolio(user_id, commodity_id);

-- Create a function to check if a user has access to a commodity
CREATE OR REPLACE FUNCTION has_commodity_access(p_user_id uuid, p_commodity_id uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM commodity_portfolio
    WHERE user_id = p_user_id 
    AND commodity_id = p_commodity_id
    AND status = 'active'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a view for active user commodities
CREATE OR REPLACE VIEW active_user_commodities AS
SELECT 
  cp.user_id,
  c.id as commodity_id,
  c.name,
  c.symbol,
  c.category,
  c.market_code,
  c.exchange,
  cp.added_at,
  cp.last_viewed_at
FROM commodity_portfolio cp
JOIN commodities c ON c.id = cp.commodity_id
WHERE cp.status = 'active';

-- Enable RLS on the view
ALTER VIEW active_user_commodities SET (security_invoker = true);

-- Update wheat_forecasts RLS policy to check portfolio access
DROP POLICY IF EXISTS "Wheat forecasts are viewable by authenticated users" ON wheat_forecasts;

CREATE POLICY "Wheat forecasts are viewable by portfolio owners"
ON wheat_forecasts FOR SELECT
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
COMMENT ON FUNCTION has_commodity_access IS 'Checks if a user has active access to a specific commodity';
COMMENT ON VIEW active_user_commodities IS 'Shows all active commodities in users portfolios';
COMMENT ON INDEX idx_commodity_portfolio_user_commodity IS 'Improves performance of commodity access checks';