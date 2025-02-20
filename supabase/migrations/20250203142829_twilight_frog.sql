-- Add email_notifications column to commodity_alerts
ALTER TABLE commodity_alerts
ADD COLUMN IF NOT EXISTS email_notifications boolean DEFAULT false;

-- Add helpful comment
COMMENT ON COLUMN commodity_alerts.email_notifications IS 'Whether email notifications are enabled for this alert';