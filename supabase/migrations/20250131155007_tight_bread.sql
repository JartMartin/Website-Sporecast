-- Insert sample data for each timeframe
DO $$
DECLARE
  v_wheat_id uuid;
  v_date date;
  v_model text := 'v2.1.0';
BEGIN
  -- Get the wheat commodity ID
  SELECT id INTO v_wheat_id
  FROM commodities
  WHERE symbol = 'WHEAT'
  LIMIT 1;

  -- Insert data for each timeframe
  FOR v_date IN 
    SELECT generate_series(
      current_date - interval '30 days',
      current_date,
      interval '1 day'
    )::date
  LOOP
    -- 1-week metrics
    INSERT INTO wheat_metrics_1w (
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
      min_past_1w,
      max_past_1w,
      min_future_1w,
      max_future_1w
    ) VALUES (
      v_wheat_id,
      v_date,
      v_model,
      '1w',
      200 + (random() * 20),
      85 + (random() * 10),
      90 + (random() * 8),
      10 + (random() * 20),
      -5 + (random() * 10),
      (ARRAY['low', 'moderate', 'high'])[floor(random() * 3 + 1)],
      (ARRAY['increasing', 'stable', 'decreasing'])[floor(random() * 3 + 1)],
      40,
      25,
      20,
      15,
      180 + (random() * 10),
      220 + (random() * 10),
      190 + (random() * 10),
      230 + (random() * 10)
    );

    -- 4-week metrics
    INSERT INTO wheat_metrics_4w (
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
      min_past_4w,
      max_past_4w,
      min_future_4w,
      max_future_4w
    ) VALUES (
      v_wheat_id,
      v_date,
      v_model,
      '4w',
      200 + (random() * 20),
      82 + (random() * 10),
      88 + (random() * 8),
      12 + (random() * 20),
      -4 + (random() * 10),
      (ARRAY['low', 'moderate', 'high'])[floor(random() * 3 + 1)],
      (ARRAY['increasing', 'stable', 'decreasing'])[floor(random() * 3 + 1)],
      40,
      25,
      20,
      15,
      175 + (random() * 10),
      225 + (random() * 10),
      185 + (random() * 10),
      235 + (random() * 10)
    );

    -- 12-week metrics
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
    ) VALUES (
      v_wheat_id,
      v_date,
      v_model,
      '12w',
      200 + (random() * 20),
      80 + (random() * 10),
      85 + (random() * 8),
      15 + (random() * 20),
      -3 + (random() * 10),
      (ARRAY['low', 'moderate', 'high'])[floor(random() * 3 + 1)],
      (ARRAY['increasing', 'stable', 'decreasing'])[floor(random() * 3 + 1)],
      40,
      25,
      20,
      15,
      170 + (random() * 10),
      230 + (random() * 10),
      180 + (random() * 10),
      240 + (random() * 10)
    );

    -- 26-week metrics
    INSERT INTO wheat_metrics_26w (
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
      min_past_26w,
      max_past_26w,
      min_future_26w,
      max_future_26w
    ) VALUES (
      v_wheat_id,
      v_date,
      v_model,
      '26w',
      200 + (random() * 20),
      78 + (random() * 10),
      82 + (random() * 8),
      18 + (random() * 20),
      -2 + (random() * 10),
      (ARRAY['low', 'moderate', 'high'])[floor(random() * 3 + 1)],
      (ARRAY['increasing', 'stable', 'decreasing'])[floor(random() * 3 + 1)],
      40,
      25,
      20,
      15,
      165 + (random() * 10),
      235 + (random() * 10),
      175 + (random() * 10),
      245 + (random() * 10)
    );

    -- 52-week metrics
    INSERT INTO wheat_metrics_52w (
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
      min_past_52w,
      max_past_52w,
      min_future_52w,
      max_future_52w
    ) VALUES (
      v_wheat_id,
      v_date,
      v_model,
      '52w',
      200 + (random() * 20),
      75 + (random() * 10),
      80 + (random() * 8),
      20 + (random() * 20),
      -1 + (random() * 10),
      (ARRAY['low', 'moderate', 'high'])[floor(random() * 3 + 1)],
      (ARRAY['increasing', 'stable', 'decreasing'])[floor(random() * 3 + 1)],
      40,
      25,
      20,
      15,
      160 + (random() * 10),
      240 + (random() * 10),
      170 + (random() * 10),
      250 + (random() * 10)
    );
  END LOOP;
END $$;

-- Update statistics for better query performance
ANALYZE wheat_metrics_1w;
ANALYZE wheat_metrics_4w;
ANALYZE wheat_metrics_12w;
ANALYZE wheat_metrics_26w;
ANALYZE wheat_metrics_52w;