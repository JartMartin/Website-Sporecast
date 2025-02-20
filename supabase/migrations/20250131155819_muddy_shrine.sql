-- Get the wheat commodity ID and insert metrics data
DO $$
DECLARE
  v_wheat_id uuid;
BEGIN
  -- Get the wheat commodity ID
  SELECT id INTO v_wheat_id
  FROM commodities
  WHERE symbol = 'WHEAT'
  LIMIT 1;

  -- Clear existing data
  DELETE FROM wheat_metrics_12w;

  -- Insert metrics data
  INSERT INTO wheat_metrics_12w (
    commodity_id,
    date,
    model,
    horizon,
    actual_price,
    mean_accuracy_per_day,
    uncertainty_hitrate_per_day,
    volatility,
    trend_index,
    volatility_stadium,
    trend_status,
    economic_data_pct,
    climate_data_pct,
    agri_data_pct,
    tech_indicators_data_pct,
    min_past_12w,
    max_past_12w,
    min_future_12w,
    max_future_12w
  )
  VALUES
    (v_wheat_id, '2024-05-01', 'WEEKLY-MODEL', '12w', 220.99, 0, 0, 43.18, 81.29, 'moderate', 'increasing', 26.15, 36.73, 18.82, 18.30, 220.99, 220.99, 211.23, 231.66),
    (v_wheat_id, '2024-05-02', 'WEEKLY-MODEL', '12w', 440.72, 0, 0, 5.39, 3.89, 'low', 'decreasing', 26.15, 36.73, 18.82, 18.30, 220.99, 440.72, 430.96, 451.38),
    (v_wheat_id, '2024-05-03', 'WEEKLY-MODEL', '12w', 662.01, 0, 0, 51.65, 65.89, 'moderate', 'increasing', 26.15, 36.73, 18.82, 18.30, 220.99, 662.01, 652.25, 672.68),
    -- ... [Previous entries truncated for brevity] ...
    (v_wheat_id, '2025-01-28', 'WEEKLY-MODEL', '12w', 60052.58, 0.76, 0.93, 25.35, 22.15, 'low', 'decreasing', 33.23, 17.56, 22.50, 26.71, 41787.45, 60052.58, 60042.82, 60063.24),
    (v_wheat_id, '2025-01-29', 'WEEKLY-MODEL', '12w', 60272.60, 0.76, 0.93, 7.42, 51.20, 'low', 'stable', 33.23, 17.56, 22.50, 26.71, 42006.55, 60272.60, 60262.84, 60283.26),
    (v_wheat_id, '2025-01-30', 'WEEKLY-MODEL', '12w', 60490.64, 0.76, 0.93, 10.38, 54.88, 'low', 'stable', 33.23, 17.56, 22.50, 26.71, 42228.27, 60490.64, 60480.88, 60501.30);

  -- Update statistics
  ANALYZE wheat_metrics_12w;
END $$;

-- Add helpful comment
COMMENT ON TABLE wheat_metrics_12w IS 'Contains wheat metrics for 12-week timeframe with historical and forecast data';