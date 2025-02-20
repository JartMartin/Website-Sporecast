-- Drop unused tables
DROP TABLE IF EXISTS commodity_forecasts CASCADE;
DROP TABLE IF EXISTS maize_forecasts CASCADE;
DROP TABLE IF EXISTS barley_forecasts CASCADE;
DROP TABLE IF EXISTS oats_forecasts CASCADE;
DROP TABLE IF EXISTS wheat_volatility CASCADE;
DROP TABLE IF EXISTS commodity_preferences CASCADE;
DROP TABLE IF EXISTS commodity_metadata CASCADE;
DROP TABLE IF EXISTS commodity_settings CASCADE;
DROP TABLE IF EXISTS user_commodities CASCADE;
DROP TABLE IF EXISTS special_commodities CASCADE;

-- Drop unused views if they exist
DROP VIEW IF EXISTS portfolio_view CASCADE;

-- Drop unused functions if they exist
DROP FUNCTION IF EXISTS handle_portfolio_operation CASCADE;
DROP FUNCTION IF EXISTS get_special_commodity_id CASCADE;

-- Add helpful comments
COMMENT ON TABLE wheat_forecasts IS 'Primary table for storing wheat price forecasts';
COMMENT ON TABLE commodity_portfolio IS 'Tracks user commodity subscriptions';
COMMENT ON TABLE commodity_alerts IS 'Stores user price alerts for commodities';

-- Verify essential tables still have proper indexes
DO $$ 
BEGIN
  -- Ensure wheat_forecasts has proper indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE tablename = 'wheat_forecasts' AND indexname = 'idx_wheat_forecasts_date'
  ) THEN
    CREATE INDEX idx_wheat_forecasts_date ON wheat_forecasts(date);
  END IF;

  -- Ensure commodity_portfolio has proper indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE tablename = 'commodity_portfolio' AND indexname = 'idx_commodity_portfolio_user'
  ) THEN
    CREATE INDEX idx_commodity_portfolio_user ON commodity_portfolio(user_id);
  END IF;

  -- Ensure commodity_alerts has proper indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE tablename = 'commodity_alerts' AND indexname = 'idx_commodity_alerts_user'
  ) THEN
    CREATE INDEX idx_commodity_alerts_user ON commodity_alerts(user_id);
  END IF;
END $$;