-- Drop existing tables if they exist
DROP TABLE IF EXISTS wheat_metrics_1w CASCADE;
DROP TABLE IF EXISTS wheat_metrics_4w CASCADE;
DROP TABLE IF EXISTS wheat_metrics_12w CASCADE;
DROP TABLE IF EXISTS wheat_metrics_26w CASCADE;
DROP TABLE IF EXISTS wheat_metrics_52w CASCADE;

-- Create base table for 1w metrics
CREATE TABLE wheat_metrics_1w (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  commodity_id uuid REFERENCES commodities(id) NOT NULL,
  date date NOT NULL,
  model text NOT NULL,
  horizon text NOT NULL,
  actual_price decimal,
  mean_accuracy_per_day decimal,
  uncertainty_hitrate_per_day decimal,
  volatility decimal,
  trend_index decimal,
  volatility_stadium text CHECK (volatility_stadium IN ('low', 'moderate', 'high')),
  trend_status text CHECK (trend_status IN ('increasing', 'stable', 'decreasing')),
  economic_data_pct decimal CHECK (economic_data_pct >= 0 AND economic_data_pct <= 100),
  climate_data_pct decimal CHECK (climate_data_pct >= 0 AND climate_data_pct <= 100),
  agri_data_pct decimal CHECK (agri_data_pct >= 0 AND agri_data_pct <= 100),
  tech_indicators_data_pct decimal CHECK (tech_indicators_data_pct >= 0 AND tech_indicators_data_pct <= 100),
  min_past_1w decimal,
  max_past_1w decimal,
  min_future_1w decimal,
  max_future_1w decimal,
  created_at timestamptz DEFAULT now(),
  UNIQUE(commodity_id, date, model),
  CONSTRAINT data_percentages_sum_100_1w 
    CHECK (economic_data_pct + climate_data_pct + agri_data_pct + tech_indicators_data_pct = 100)
);

-- Create other timeframe tables by cloning 1w table
CREATE TABLE wheat_metrics_4w (LIKE wheat_metrics_1w INCLUDING ALL);
ALTER TABLE wheat_metrics_4w 
  RENAME COLUMN min_past_1w TO min_past_4w;
ALTER TABLE wheat_metrics_4w 
  RENAME COLUMN max_past_1w TO max_past_4w;
ALTER TABLE wheat_metrics_4w 
  RENAME COLUMN min_future_1w TO min_future_4w;
ALTER TABLE wheat_metrics_4w 
  RENAME COLUMN max_future_1w TO max_future_4w;
ALTER TABLE wheat_metrics_4w 
  RENAME CONSTRAINT data_percentages_sum_100_1w TO data_percentages_sum_100_4w;

CREATE TABLE wheat_metrics_12w (LIKE wheat_metrics_1w INCLUDING ALL);
ALTER TABLE wheat_metrics_12w 
  RENAME COLUMN min_past_1w TO min_past_12w;
ALTER TABLE wheat_metrics_12w 
  RENAME COLUMN max_past_1w TO max_past_12w;
ALTER TABLE wheat_metrics_12w 
  RENAME COLUMN min_future_1w TO min_future_12w;
ALTER TABLE wheat_metrics_12w 
  RENAME COLUMN max_future_1w TO max_future_12w;
ALTER TABLE wheat_metrics_12w 
  RENAME CONSTRAINT data_percentages_sum_100_1w TO data_percentages_sum_100_12w;

CREATE TABLE wheat_metrics_26w (LIKE wheat_metrics_1w INCLUDING ALL);
ALTER TABLE wheat_metrics_26w 
  RENAME COLUMN min_past_1w TO min_past_26w;
ALTER TABLE wheat_metrics_26w 
  RENAME COLUMN max_past_1w TO max_past_26w;
ALTER TABLE wheat_metrics_26w 
  RENAME COLUMN min_future_1w TO min_future_26w;
ALTER TABLE wheat_metrics_26w 
  RENAME COLUMN max_future_1w TO max_future_26w;
ALTER TABLE wheat_metrics_26w 
  RENAME CONSTRAINT data_percentages_sum_100_1w TO data_percentages_sum_100_26w;

CREATE TABLE wheat_metrics_52w (LIKE wheat_metrics_1w INCLUDING ALL);
ALTER TABLE wheat_metrics_52w 
  RENAME COLUMN min_past_1w TO min_past_52w;
ALTER TABLE wheat_metrics_52w 
  RENAME COLUMN max_past_1w TO max_past_52w;
ALTER TABLE wheat_metrics_52w 
  RENAME COLUMN min_future_1w TO min_future_52w;
ALTER TABLE wheat_metrics_52w 
  RENAME COLUMN max_future_1w TO max_future_52w;
ALTER TABLE wheat_metrics_52w 
  RENAME CONSTRAINT data_percentages_sum_100_1w TO data_percentages_sum_100_52w;

-- Enable RLS for all tables
ALTER TABLE wheat_metrics_1w ENABLE ROW LEVEL SECURITY;
ALTER TABLE wheat_metrics_4w ENABLE ROW LEVEL SECURITY;
ALTER TABLE wheat_metrics_12w ENABLE ROW LEVEL SECURITY;
ALTER TABLE wheat_metrics_26w ENABLE ROW LEVEL SECURITY;
ALTER TABLE wheat_metrics_52w ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for all tables
CREATE POLICY "Wheat metrics 1w are viewable by portfolio owners"
  ON wheat_metrics_1w FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 
      FROM commodity_portfolio cp
      WHERE cp.commodity_id = wheat_metrics_1w.commodity_id
      AND cp.user_id = auth.uid()
      AND cp.status = 'active'
    )
  );

CREATE POLICY "Wheat metrics 4w are viewable by portfolio owners"
  ON wheat_metrics_4w FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 
      FROM commodity_portfolio cp
      WHERE cp.commodity_id = wheat_metrics_4w.commodity_id
      AND cp.user_id = auth.uid()
      AND cp.status = 'active'
    )
  );

CREATE POLICY "Wheat metrics 12w are viewable by portfolio owners"
  ON wheat_metrics_12w FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 
      FROM commodity_portfolio cp
      WHERE cp.commodity_id = wheat_metrics_12w.commodity_id
      AND cp.user_id = auth.uid()
      AND cp.status = 'active'
    )
  );

CREATE POLICY "Wheat metrics 26w are viewable by portfolio owners"
  ON wheat_metrics_26w FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 
      FROM commodity_portfolio cp
      WHERE cp.commodity_id = wheat_metrics_26w.commodity_id
      AND cp.user_id = auth.uid()
      AND cp.status = 'active'
    )
  );

CREATE POLICY "Wheat metrics 52w are viewable by portfolio owners"
  ON wheat_metrics_52w FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 
      FROM commodity_portfolio cp
      WHERE cp.commodity_id = wheat_metrics_52w.commodity_id
      AND cp.user_id = auth.uid()
      AND cp.status = 'active'
    )
  );

-- Create indexes for all tables
CREATE INDEX idx_wheat_metrics_1w_date ON wheat_metrics_1w(date);
CREATE INDEX idx_wheat_metrics_1w_commodity ON wheat_metrics_1w(commodity_id);

CREATE INDEX idx_wheat_metrics_4w_date ON wheat_metrics_4w(date);
CREATE INDEX idx_wheat_metrics_4w_commodity ON wheat_metrics_4w(commodity_id);

CREATE INDEX idx_wheat_metrics_12w_date ON wheat_metrics_12w(date);
CREATE INDEX idx_wheat_metrics_12w_commodity ON wheat_metrics_12w(commodity_id);

CREATE INDEX idx_wheat_metrics_26w_date ON wheat_metrics_26w(date);
CREATE INDEX idx_wheat_metrics_26w_commodity ON wheat_metrics_26w(commodity_id);

CREATE INDEX idx_wheat_metrics_52w_date ON wheat_metrics_52w(date);
CREATE INDEX idx_wheat_metrics_52w_commodity ON wheat_metrics_52w(commodity_id);

-- Add helpful comments
COMMENT ON TABLE wheat_metrics_1w IS 'Contains wheat metrics for 1-week timeframe';
COMMENT ON TABLE wheat_metrics_4w IS 'Contains wheat metrics for 4-week timeframe';
COMMENT ON TABLE wheat_metrics_12w IS 'Contains wheat metrics for 12-week timeframe';
COMMENT ON TABLE wheat_metrics_26w IS 'Contains wheat metrics for 26-week timeframe';
COMMENT ON TABLE wheat_metrics_52w IS 'Contains wheat metrics for 52-week timeframe';

-- Add column comments (for 1w table, similar for others)
COMMENT ON COLUMN wheat_metrics_1w.model IS 'Model version used for predictions';
COMMENT ON COLUMN wheat_metrics_1w.horizon IS 'Forecast horizon (e.g., 1w, 4w, etc.)';
COMMENT ON COLUMN wheat_metrics_1w.mean_accuracy_per_day IS 'Average prediction accuracy per day';
COMMENT ON COLUMN wheat_metrics_1w.uncertainty_hitrate_per_day IS 'Percentage of actual prices within confidence intervals';
COMMENT ON COLUMN wheat_metrics_1w.volatility IS 'Market volatility index';
COMMENT ON COLUMN wheat_metrics_1w.trend_index IS 'Market trend strength indicator';
COMMENT ON COLUMN wheat_metrics_1w.volatility_stadium IS 'Current volatility level assessment';
COMMENT ON COLUMN wheat_metrics_1w.trend_status IS 'Current trend direction assessment';
COMMENT ON COLUMN wheat_metrics_1w.economic_data_pct IS 'Percentage influence of economic data';
COMMENT ON COLUMN wheat_metrics_1w.climate_data_pct IS 'Percentage influence of climate data';
COMMENT ON COLUMN wheat_metrics_1w.agri_data_pct IS 'Percentage influence of agricultural data';
COMMENT ON COLUMN wheat_metrics_1w.tech_indicators_data_pct IS 'Percentage influence of technical indicators';