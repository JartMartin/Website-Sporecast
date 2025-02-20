-- Drop the general commodity_forecasts table
DROP TABLE IF EXISTS commodity_forecasts CASCADE;

-- Create tables for Maize
CREATE TABLE maize_forecasts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_confidence CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  UNIQUE(date)
);

CREATE TABLE maize_volatility (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  volatility_index decimal NOT NULL CHECK (volatility_index >= 0),
  trend text CHECK (trend IN ('increasing', 'decreasing', 'stable')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(date)
);

-- Create tables for Barley
CREATE TABLE barley_forecasts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_confidence CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  UNIQUE(date)
);

CREATE TABLE barley_volatility (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  volatility_index decimal NOT NULL CHECK (volatility_index >= 0),
  trend text CHECK (trend IN ('increasing', 'decreasing', 'stable')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(date)
);

-- Create tables for Oats
CREATE TABLE oats_forecasts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_confidence CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  UNIQUE(date)
);

CREATE TABLE oats_volatility (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  volatility_index decimal NOT NULL CHECK (volatility_index >= 0),
  trend text CHECK (trend IN ('increasing', 'decreasing', 'stable')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(date)
);

-- Enable RLS for all tables
ALTER TABLE maize_forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE maize_volatility ENABLE ROW LEVEL SECURITY;
ALTER TABLE barley_forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE barley_volatility ENABLE ROW LEVEL SECURITY;
ALTER TABLE oats_forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE oats_volatility ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for all tables
CREATE POLICY "Maize forecasts are viewable by authenticated users"
  ON maize_forecasts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Maize volatility data is viewable by authenticated users"
  ON maize_volatility FOR SELECT TO authenticated USING (true);
CREATE POLICY "Barley forecasts are viewable by authenticated users"
  ON barley_forecasts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Barley volatility data is viewable by authenticated users"
  ON barley_volatility FOR SELECT TO authenticated USING (true);
CREATE POLICY "Oats forecasts are viewable by authenticated users"
  ON oats_forecasts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Oats volatility data is viewable by authenticated users"
  ON oats_volatility FOR SELECT TO authenticated USING (true);

-- Create indexes for better performance
CREATE INDEX idx_maize_forecasts_date ON maize_forecasts(date);
CREATE INDEX idx_maize_volatility_date ON maize_volatility(date);
CREATE INDEX idx_barley_forecasts_date ON barley_forecasts(date);
CREATE INDEX idx_barley_volatility_date ON barley_volatility(date);
CREATE INDEX idx_oats_forecasts_date ON oats_forecasts(date);
CREATE INDEX idx_oats_volatility_date ON oats_volatility(date);

-- Insert sample data for each commodity
DO $$
DECLARE
  v_date date;
  v_base_price decimal;
  v_confidence_range decimal;
BEGIN
  -- Insert data for Maize
  v_base_price := 180;
  v_confidence_range := 12;
  
  -- Historical data
  INSERT INTO maize_forecasts (date, price, is_forecast)
  SELECT 
    d::date,
    v_base_price + (random() * 15),
    false
  FROM generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

  -- Forecast data
  INSERT INTO maize_forecasts (date, price, is_forecast, confidence_lower, confidence_upper)
  SELECT 
    d::date,
    v_base_price + 15 + (random() * 20),
    true,
    v_base_price + 15 + (random() * 20) - v_confidence_range,
    v_base_price + 15 + (random() * 20) + v_confidence_range
  FROM generate_series('2025-01-22', '2025-02-22', interval '1 day') AS d;

  -- Insert data for Barley
  v_base_price := 160;
  v_confidence_range := 10;
  
  -- Historical data
  INSERT INTO barley_forecasts (date, price, is_forecast)
  SELECT 
    d::date,
    v_base_price + (random() * 12),
    false
  FROM generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

  -- Forecast data
  INSERT INTO barley_forecasts (date, price, is_forecast, confidence_lower, confidence_upper)
  SELECT 
    d::date,
    v_base_price + 12 + (random() * 18),
    true,
    v_base_price + 12 + (random() * 18) - v_confidence_range,
    v_base_price + 12 + (random() * 18) + v_confidence_range
  FROM generate_series('2025-01-22', '2025-02-22', interval '1 day') AS d;

  -- Insert data for Oats
  v_base_price := 140;
  v_confidence_range := 8;
  
  -- Historical data
  INSERT INTO oats_forecasts (date, price, is_forecast)
  SELECT 
    d::date,
    v_base_price + (random() * 10),
    false
  FROM generate_series('2024-12-21', '2025-01-21', interval '1 day') AS d;

  -- Forecast data
  INSERT INTO oats_forecasts (date, price, is_forecast, confidence_lower, confidence_upper)
  SELECT 
    d::date,
    v_base_price + 10 + (random() * 15),
    true,
    v_base_price + 10 + (random() * 15) - v_confidence_range,
    v_base_price + 10 + (random() * 15) + v_confidence_range
  FROM generate_series('2025-01-22', '2025-02-22', interval '1 day') AS d;

  -- Insert volatility data for all commodities
  FOR v_date IN SELECT generate_series('2024-12-21', '2025-01-21', interval '1 day')::date LOOP
    -- Maize volatility
    INSERT INTO maize_volatility (date, volatility_index, trend)
    VALUES (
      v_date,
      8 + (random() * 12),
      CASE 
        WHEN random() < 0.33 THEN 'increasing'
        WHEN random() < 0.66 THEN 'decreasing'
        ELSE 'stable'
      END
    );

    -- Barley volatility
    INSERT INTO barley_volatility (date, volatility_index, trend)
    VALUES (
      v_date,
      6 + (random() * 10),
      CASE 
        WHEN random() < 0.33 THEN 'increasing'
        WHEN random() < 0.66 THEN 'decreasing'
        ELSE 'stable'
      END
    );

    -- Oats volatility
    INSERT INTO oats_volatility (date, volatility_index, trend)
    VALUES (
      v_date,
      5 + (random() * 8),
      CASE 
        WHEN random() < 0.33 THEN 'increasing'
        WHEN random() < 0.66 THEN 'decreasing'
        ELSE 'stable'
      END
    );
  END LOOP;
END $$;

-- Add helpful comments
COMMENT ON TABLE maize_forecasts IS 'Stores historical prices and price forecasts for maize';
COMMENT ON TABLE maize_volatility IS 'Stores historical volatility data for maize';
COMMENT ON TABLE barley_forecasts IS 'Stores historical prices and price forecasts for barley';
COMMENT ON TABLE barley_volatility IS 'Stores historical volatility data for barley';
COMMENT ON TABLE oats_forecasts IS 'Stores historical prices and price forecasts for oats';
COMMENT ON TABLE oats_volatility IS 'Stores historical volatility data for oats';