-- Drop unused tables and related objects
DO $$ 
BEGIN
  -- Drop commodity-specific forecast tables (replaced by wheat_forecasts)
  DROP TABLE IF EXISTS commodity_forecasts CASCADE;
  DROP TABLE IF EXISTS maize_forecasts CASCADE;
  DROP TABLE IF EXISTS barley_forecasts CASCADE;
  DROP TABLE IF EXISTS oats_forecasts CASCADE;

  -- Drop unused volatility tables
  DROP TABLE IF EXISTS wheat_volatility CASCADE;
  DROP TABLE IF EXISTS maize_volatility CASCADE;
  DROP TABLE IF EXISTS barley_volatility CASCADE;
  DROP TABLE IF EXISTS oats_volatility CASCADE;

  -- Drop unused preference and metadata tables
  DROP TABLE IF EXISTS commodity_preferences CASCADE;
  DROP TABLE IF EXISTS commodity_metadata CASCADE;
  DROP TABLE IF EXISTS commodity_settings CASCADE;

  -- Drop replaced tables
  DROP TABLE IF EXISTS user_commodities CASCADE;
  DROP TABLE IF EXISTS special_commodities CASCADE;
END $$;

-- Add helpful comments
COMMENT ON TABLE wheat_forecasts IS 'Primary table for storing wheat price forecasts';
COMMENT ON TABLE commodity_portfolio IS 'Tracks user commodity subscriptions';
COMMENT ON TABLE commodity_alerts IS 'Stores user price alerts for commodities';