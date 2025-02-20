-- Drop all unused tables
DROP TABLE IF EXISTS commodity_portfolio CASCADE;
DROP TABLE IF EXISTS commodity_alerts CASCADE;
DROP TABLE IF EXISTS commodity_forecasts CASCADE;
DROP TABLE IF EXISTS wheat_forecasts CASCADE;
DROP TABLE IF EXISTS wheat_forecasts_1w CASCADE;
DROP TABLE IF EXISTS wheat_forecasts_4w CASCADE;
DROP TABLE IF EXISTS wheat_forecasts_12w CASCADE;
DROP TABLE IF EXISTS wheat_forecasts_26w CASCADE;
DROP TABLE IF EXISTS wheat_forecasts_52w CASCADE;
DROP TABLE IF EXISTS wheat_metrics_1w CASCADE;
DROP TABLE IF EXISTS wheat_metrics_4w CASCADE;
DROP TABLE IF EXISTS wheat_metrics_12w CASCADE;
DROP TABLE IF EXISTS wheat_metrics_26w CASCADE;
DROP TABLE IF EXISTS wheat_metrics_52w CASCADE;
DROP TABLE IF EXISTS wheat_master_table CASCADE;
DROP TABLE IF EXISTS wheat_volatility CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS company_invites CASCADE;

-- Optimize profiles table
ALTER TABLE profiles
DROP COLUMN IF EXISTS company_id CASCADE,
DROP COLUMN IF EXISTS company_role CASCADE;

-- Create optimized view for catalog display
CREATE OR REPLACE VIEW catalog_view AS
SELECT 
  c.id,
  c.name,
  c.category,
  c.market_code,
  c.exchange,
  c.status,
  c.description,
  COUNT(n.id) as notification_count
FROM catalog_commodities c
LEFT JOIN catalog_notifications n ON c.id = n.commodity_id AND n.status = 'active'
GROUP BY c.id, c.name, c.category, c.market_code, c.exchange, c.status, c.description;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_catalog_notifications_commodity_status 
ON catalog_notifications(commodity_id, status) 
WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_scheduled_meetings_date_time 
ON scheduled_meetings(meeting_date, meeting_time) 
WHERE status = 'scheduled';

-- Add helpful comments
COMMENT ON VIEW catalog_view IS 'Optimized view of catalog commodities with notification counts';
COMMENT ON TABLE profiles IS 'Basic user profile information';
COMMENT ON TABLE scheduled_meetings IS 'Online coffee meeting schedule';
COMMENT ON TABLE catalog_commodities IS 'Available and upcoming commodities';
COMMENT ON TABLE catalog_requests IS 'New commodity requests from users';
COMMENT ON TABLE catalog_notifications IS 'Notifications for upcoming commodities';
COMMENT ON TABLE waitlist_entries IS 'Waitlist for platform launch';