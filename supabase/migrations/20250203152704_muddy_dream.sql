-- Add new columns to commodity_alerts table
ALTER TABLE commodity_alerts
ADD COLUMN IF NOT EXISTS approaching_trigger boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS progress_to_trigger decimal CHECK (progress_to_trigger >= 0 AND progress_to_trigger <= 100),
ADD COLUMN IF NOT EXISTS last_check_price decimal,
ADD COLUMN IF NOT EXISTS last_check_at timestamptz;

-- Create index for better alert checking performance
CREATE INDEX IF NOT EXISTS idx_commodity_alerts_active_check 
ON commodity_alerts(is_active, last_check_at) 
WHERE is_active = true;

-- Create function to update alert progress
CREATE OR REPLACE FUNCTION update_alert_progress()
RETURNS trigger AS $$
BEGIN
  -- Calculate progress to trigger
  IF NEW.type = 'price_above' THEN
    NEW.progress_to_trigger := LEAST(((NEW.last_check_price / NEW.threshold) * 100), 100);
    NEW.approaching_trigger := NEW.progress_to_trigger >= 90;
  ELSE
    NEW.progress_to_trigger := LEAST(((NEW.threshold / NEW.last_check_price) * 100), 100);
    NEW.approaching_trigger := NEW.progress_to_trigger >= 90;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update progress
CREATE TRIGGER alert_progress_update
  BEFORE UPDATE OF last_check_price ON commodity_alerts
  FOR EACH ROW
  EXECUTE FUNCTION update_alert_progress();

-- Add helpful comments
COMMENT ON COLUMN commodity_alerts.approaching_trigger IS 'Whether the price is close to triggering the alert';
COMMENT ON COLUMN commodity_alerts.progress_to_trigger IS 'Percentage progress towards triggering the alert (0-100)';
COMMENT ON COLUMN commodity_alerts.last_check_price IS 'Last price checked for this alert';
COMMENT ON COLUMN commodity_alerts.last_check_at IS 'Timestamp of last price check';