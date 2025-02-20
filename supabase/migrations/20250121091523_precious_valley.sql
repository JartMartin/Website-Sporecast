/*
  # Create price forecast table

  1. New Tables
    - `commodity_forecasts`
      - `id` (uuid, primary key)
      - `commodity_id` (uuid, references commodities)
      - `date` (date)
      - `price` (decimal)
      - `is_forecast` (boolean)
      - `confidence_lower` (decimal, nullable)
      - `confidence_upper` (decimal, nullable)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS
    - Add policy for authenticated users to view forecasts
*/

-- Create commodity_forecasts table
CREATE TABLE commodity_forecasts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_confidence CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  )
);

-- Enable RLS
ALTER TABLE commodity_forecasts ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing forecasts
CREATE POLICY "Forecasts are viewable by authenticated users"
  ON commodity_forecasts FOR SELECT
  TO authenticated
  USING (true);

-- Create index for better query performance
CREATE INDEX idx_commodity_forecasts_commodity_date 
  ON commodity_forecasts(commodity_id, date);

-- Insert sample data for Wheat (past 30 days and next 30 days forecast)
WITH wheat_id AS (
  SELECT id FROM commodities WHERE symbol = 'WHEAT' LIMIT 1
),
date_series AS (
  SELECT generate_series(
    current_date - interval '30 days',
    current_date + interval '30 days',
    interval '1 day'
  )::date as date
)
INSERT INTO commodity_forecasts (commodity_id, date, price, is_forecast, confidence_lower, confidence_upper)
SELECT 
  wheat_id.id,
  date_series.date,
  -- Generate realistic price data with volatility
  180 + (20 * sin(extract(epoch from date_series.date) / 86400 / 7)) + (random() * 10),
  date_series.date > current_date,
  CASE 
    WHEN date_series.date > current_date THEN
      180 + (20 * sin(extract(epoch from date_series.date) / 86400 / 7)) + (random() * 10) - 15
    ELSE NULL
  END,
  CASE 
    WHEN date_series.date > current_date THEN
      180 + (20 * sin(extract(epoch from date_series.date) / 86400 / 7)) + (random() * 10) + 15
    ELSE NULL
  END
FROM date_series, wheat_id;

-- Add helpful comments
COMMENT ON TABLE commodity_forecasts IS 'Stores historical prices and price forecasts for commodities';
COMMENT ON COLUMN commodity_forecasts.is_forecast IS 'Whether this is a historical price (false) or forecast (true)';
COMMENT ON COLUMN commodity_forecasts.confidence_lower IS 'Lower bound of 90% confidence interval for forecasts';
COMMENT ON COLUMN commodity_forecasts.confidence_upper IS 'Upper bound of 90% confidence interval for forecasts';