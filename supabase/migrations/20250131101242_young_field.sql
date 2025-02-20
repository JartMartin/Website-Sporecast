-- Add new columns to commodities table
ALTER TABLE commodities
ADD COLUMN IF NOT EXISTS display_name text,
ADD COLUMN IF NOT EXISTS trading_hours_start text,
ADD COLUMN IF NOT EXISTS trading_hours_end text,
ADD COLUMN IF NOT EXISTS trading_hours_timezone text,
ADD COLUMN IF NOT EXISTS delivery_months jsonb DEFAULT '[]'::jsonb;

-- Update the wheat commodity with the correct information
UPDATE commodities
SET 
  name = 'Milling Wheat / Blé de Meunerie',
  display_name = 'Milling Wheat / Blé de Meunerie',
  market_code = 'EBM',
  exchange = 'Euronext',
  trading_hours_start = '10:45',
  trading_hours_end = '18:30',
  trading_hours_timezone = 'CET',
  delivery_months = '["Mar 2025", "May 2025", "Jul 2025", "Sep 2025", "Dec 2025"]'::jsonb
WHERE symbol = 'WHEAT';

-- Add helpful comments
COMMENT ON COLUMN commodities.display_name IS 'Display name for the commodity (can be different from name)';
COMMENT ON COLUMN commodities.trading_hours_start IS 'Start time of trading hours';
COMMENT ON COLUMN commodities.trading_hours_end IS 'End time of trading hours';
COMMENT ON COLUMN commodities.trading_hours_timezone IS 'Timezone for trading hours';
COMMENT ON COLUMN commodities.delivery_months IS 'Array of delivery months in format "MMM YYYY"';