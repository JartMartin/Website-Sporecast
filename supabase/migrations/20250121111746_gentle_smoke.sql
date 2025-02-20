-- Create a function to generate forecast tables for a commodity
CREATE OR REPLACE FUNCTION create_commodity_tables(commodity_name text)
RETURNS void AS $$
BEGIN
  -- Create forecasts table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I_forecasts (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      date date NOT NULL,
      price decimal NOT NULL,
      is_forecast boolean DEFAULT false,
      confidence_lower decimal,
      confidence_upper decimal,
      created_at timestamptz DEFAULT now(),
      CONSTRAINT %I_forecasts_valid_confidence CHECK (
        (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
        (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
      ),
      UNIQUE(date)
    )', commodity_name, commodity_name);

  -- Create volatility table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I_volatility (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      date date NOT NULL,
      volatility_index decimal NOT NULL CHECK (volatility_index >= 0),
      trend text CHECK (trend IN (''increasing'', ''decreasing'', ''stable'')),
      created_at timestamptz DEFAULT now(),
      UNIQUE(date)
    )', commodity_name);

  -- Enable RLS
  EXECUTE format('ALTER TABLE %I_forecasts ENABLE ROW LEVEL SECURITY', commodity_name);
  EXECUTE format('ALTER TABLE %I_volatility ENABLE ROW LEVEL SECURITY', commodity_name);

  -- Create RLS policies
  EXECUTE format('
    CREATE POLICY "%1$s forecasts are viewable by authenticated users"
    ON %1$s_forecasts FOR SELECT
    TO authenticated
    USING (true)
  ', commodity_name);

  EXECUTE format('
    CREATE POLICY "%1$s volatility data is viewable by authenticated users"
    ON %1$s_volatility FOR SELECT
    TO authenticated
    USING (true)
  ', commodity_name);

  -- Create indexes
  EXECUTE format('
    CREATE INDEX IF NOT EXISTS idx_%1$s_forecasts_date 
    ON %1$s_forecasts(date)
  ', commodity_name);

  EXECUTE format('
    CREATE INDEX IF NOT EXISTS idx_%1$s_volatility_date 
    ON %1$s_volatility(date)
  ', commodity_name);
END;
$$ LANGUAGE plpgsql;

-- Create tables for each commodity
SELECT create_commodity_tables('wheat');
SELECT create_commodity_tables('maize');
SELECT create_commodity_tables('barley');
SELECT create_commodity_tables('oats');

-- Insert sample data for each commodity
DO $$
DECLARE
  commodity RECORD;
  base_price decimal;
  confidence_range decimal;
BEGIN
  -- Define base prices and confidence ranges for each commodity
  FOR commodity IN 
    SELECT 
      symbol,
      CASE 
        WHEN symbol = 'WHEAT' THEN 200
        WHEN symbol = 'MAIZE' THEN 180
        WHEN symbol = 'BARLEY' THEN 160
        WHEN symbol = 'OATS' THEN 140
      END as base_price,
      CASE 
        WHEN symbol = 'WHEAT' THEN 15
        WHEN symbol = 'MAIZE' THEN 12
        WHEN symbol = 'BARLEY' THEN 10
        WHEN symbol = 'OATS' THEN 8
      END as confidence_range
    FROM commodities 
    WHERE status = 'available'
  LOOP
    -- Insert historical data
    EXECUTE format('
      INSERT INTO %I_forecasts (date, price, is_forecast)
      SELECT 
        d::date,
        %s + (random() * 20),
        false
      FROM generate_series(''2024-12-21'', ''2025-01-21'', interval ''1 day'') AS d',
      lower(commodity.symbol), commodity.base_price
    );

    -- Insert forecast data
    EXECUTE format('
      INSERT INTO %I_forecasts (date, price, is_forecast, confidence_lower, confidence_upper)
      SELECT 
        d::date,
        %s + 20 + (random() * 25),
        true,
        %s + 20 + (random() * 25) - %s,
        %s + 20 + (random() * 25) + %s
      FROM generate_series(''2025-01-22'', ''2025-02-22'', interval ''1 day'') AS d',
      lower(commodity.symbol), 
      commodity.base_price, 
      commodity.base_price,
      commodity.confidence_range,
      commodity.base_price,
      commodity.confidence_range
    );

    -- Insert volatility data
    EXECUTE format('
      INSERT INTO %I_volatility (date, volatility_index, trend)
      SELECT 
        d::date,
        %s + (random() * 15),
        CASE 
          WHEN random() < 0.33 THEN ''increasing''
          WHEN random() < 0.66 THEN ''decreasing''
          ELSE ''stable''
        END
      FROM generate_series(''2024-12-21'', ''2025-01-21'', interval ''1 day'') AS d',
      lower(commodity.symbol),
      commodity.confidence_range * 0.8 -- Base volatility on confidence range
    );
  END LOOP;
END $$;

-- Add helpful comments
COMMENT ON FUNCTION create_commodity_tables IS 'Creates forecast and volatility tables for a given commodity';