-- Drop existing tables if they exist
DROP TABLE IF EXISTS wheat_forecasts_1w CASCADE;
DROP TABLE IF EXISTS wheat_forecasts_4w CASCADE;
DROP TABLE IF EXISTS wheat_forecasts_12w CASCADE;
DROP TABLE IF EXISTS wheat_forecasts_26w CASCADE;
DROP TABLE IF EXISTS wheat_forecasts_52w CASCADE;

-- Create timeframe-specific forecast tables for wheat
CREATE TABLE wheat_forecasts_1w (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  price_1y_ago decimal,
  price_2y_ago decimal,
  created_at timestamptz DEFAULT now(),
  commodity_id uuid REFERENCES commodities(id) NOT NULL,
  CONSTRAINT valid_confidence_1w CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  UNIQUE(commodity_id, date)
);

CREATE TABLE wheat_forecasts_4w (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  price_1y_ago decimal,
  price_2y_ago decimal,
  created_at timestamptz DEFAULT now(),
  commodity_id uuid REFERENCES commodities(id) NOT NULL,
  CONSTRAINT valid_confidence_4w CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  UNIQUE(commodity_id, date)
);

CREATE TABLE wheat_forecasts_12w (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  price_1y_ago decimal,
  price_2y_ago decimal,
  created_at timestamptz DEFAULT now(),
  commodity_id uuid REFERENCES commodities(id) NOT NULL,
  CONSTRAINT valid_confidence_12w CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  UNIQUE(commodity_id, date)
);

CREATE TABLE wheat_forecasts_26w (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  price_1y_ago decimal,
  price_2y_ago decimal,
  created_at timestamptz DEFAULT now(),
  commodity_id uuid REFERENCES commodities(id) NOT NULL,
  CONSTRAINT valid_confidence_26w CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  UNIQUE(commodity_id, date)
);

CREATE TABLE wheat_forecasts_52w (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  price decimal NOT NULL,
  is_forecast boolean DEFAULT false,
  confidence_lower decimal,
  confidence_upper decimal,
  price_1y_ago decimal,
  price_2y_ago decimal,
  created_at timestamptz DEFAULT now(),
  commodity_id uuid REFERENCES commodities(id) NOT NULL,
  CONSTRAINT valid_confidence_52w CHECK (
    (is_forecast = false AND confidence_lower IS NULL AND confidence_upper IS NULL) OR
    (is_forecast = true AND confidence_lower IS NOT NULL AND confidence_upper IS NOT NULL)
  ),
  UNIQUE(commodity_id, date)
);

-- Enable RLS on all tables
ALTER TABLE wheat_forecasts_1w ENABLE ROW LEVEL SECURITY;
ALTER TABLE wheat_forecasts_4w ENABLE ROW LEVEL SECURITY;
ALTER TABLE wheat_forecasts_12w ENABLE ROW LEVEL SECURITY;
ALTER TABLE wheat_forecasts_26w ENABLE ROW LEVEL SECURITY;
ALTER TABLE wheat_forecasts_52w ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for each table
CREATE POLICY "Wheat forecasts 1w are viewable by portfolio owners"
ON wheat_forecasts_1w FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM commodities c
    JOIN commodity_portfolio cp ON cp.commodity_id = c.id
    WHERE c.symbol = 'WHEAT'
    AND cp.user_id = auth.uid()
    AND cp.status = 'active'
  )
);

CREATE POLICY "Wheat forecasts 4w are viewable by portfolio owners"
ON wheat_forecasts_4w FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM commodities c
    JOIN commodity_portfolio cp ON cp.commodity_id = c.id
    WHERE c.symbol = 'WHEAT'
    AND cp.user_id = auth.uid()
    AND cp.status = 'active'
  )
);

CREATE POLICY "Wheat forecasts 12w are viewable by portfolio owners"
ON wheat_forecasts_12w FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM commodities c
    JOIN commodity_portfolio cp ON cp.commodity_id = c.id
    WHERE c.symbol = 'WHEAT'
    AND cp.user_id = auth.uid()
    AND cp.status = 'active'
  )
);

CREATE POLICY "Wheat forecasts 26w are viewable by portfolio owners"
ON wheat_forecasts_26w FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM commodities c
    JOIN commodity_portfolio cp ON cp.commodity_id = c.id
    WHERE c.symbol = 'WHEAT'
    AND cp.user_id = auth.uid()
    AND cp.status = 'active'
  )
);

CREATE POLICY "Wheat forecasts 52w are viewable by portfolio owners"
ON wheat_forecasts_52w FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM commodities c
    JOIN commodity_portfolio cp ON cp.commodity_id = c.id
    WHERE c.symbol = 'WHEAT'
    AND cp.user_id = auth.uid()
    AND cp.status = 'active'
  )
);

-- Create indexes for better query performance
CREATE INDEX idx_wheat_forecasts_1w_date ON wheat_forecasts_1w(date);
CREATE INDEX idx_wheat_forecasts_4w_date ON wheat_forecasts_4w(date);
CREATE INDEX idx_wheat_forecasts_12w_date ON wheat_forecasts_12w(date);
CREATE INDEX idx_wheat_forecasts_26w_date ON wheat_forecasts_26w(date);
CREATE INDEX idx_wheat_forecasts_52w_date ON wheat_forecasts_52w(date);

-- Add helpful comments
COMMENT ON TABLE wheat_forecasts_1w IS 'Contains 1-week wheat price forecasts with 75/25 historical/forecast ratio';
COMMENT ON TABLE wheat_forecasts_4w IS 'Contains 4-week wheat price forecasts with 75/25 historical/forecast ratio';
COMMENT ON TABLE wheat_forecasts_12w IS 'Contains 12-week wheat price forecasts with 75/25 historical/forecast ratio';
COMMENT ON TABLE wheat_forecasts_26w IS 'Contains 26-week wheat price forecasts with 75/25 historical/forecast ratio';
COMMENT ON TABLE wheat_forecasts_52w IS 'Contains 52-week wheat price forecasts with 75/25 historical/forecast ratio';