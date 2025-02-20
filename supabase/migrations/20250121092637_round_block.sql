-- Delete existing forecast data
DELETE FROM commodity_forecasts;

-- Insert sample data for Wheat with specific date ranges
WITH wheat_id AS (
  SELECT id FROM commodities WHERE symbol = 'WHEAT' LIMIT 1
),
date_series AS (
  SELECT generate_series(
    '2024-12-21'::date,
    '2025-02-22'::date,
    interval '1 day'
  )::date as date
)
INSERT INTO commodity_forecasts (commodity_id, date, price, is_forecast, confidence_lower, confidence_upper)
SELECT 
  wheat_id.id,
  date_series.date,
  -- Generate realistic price data with volatility
  180 + (20 * sin(extract(epoch from date_series.date) / 86400 / 7)) + (random() * 10),
  date_series.date > '2025-01-21'::date,
  CASE 
    WHEN date_series.date > '2025-01-21'::date THEN
      180 + (20 * sin(extract(epoch from date_series.date) / 86400 / 7)) + (random() * 10) - 15
    ELSE NULL
  END,
  CASE 
    WHEN date_series.date > '2025-01-21'::date THEN
      180 + (20 * sin(extract(epoch from date_series.date) / 86400 / 7)) + (random() * 10) + 15
    ELSE NULL
  END
FROM date_series, wheat_id;