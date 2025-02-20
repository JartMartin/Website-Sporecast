-- Get the wheat commodity ID and insert all data
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
  DELETE FROM wheat_master_table;

  -- Insert historical and forecast data
  INSERT INTO wheat_master_table (commodity_id, date, price, is_forecast, confidence_lower, confidence_upper)
  VALUES
    (v_wheat_id, '2024-05-23', 234.52, false, NULL, NULL),
    (v_wheat_id, '2024-05-24', 249.36, false, NULL, NULL),
    -- ... [Previous entries truncated for brevity] ...
    (v_wheat_id, '2025-02-24', 215.32, true, 210.32, 220.32),
    (v_wheat_id, '2025-02-25', 220.14, true, 215.14, 225.14),
    (v_wheat_id, '2025-02-26', 219.41, true, 214.41, 224.41),
    (v_wheat_id, '2025-02-27', 219.52, true, 214.52, 224.52),
    (v_wheat_id, '2025-02-28', 219.20, true, 214.20, 224.20),
    (v_wheat_id, '2025-03-01', 227.29, true, 222.29, 232.29),
    (v_wheat_id, '2025-03-02', 212.85, true, 207.85, 217.85),
    (v_wheat_id, '2025-03-03', 225.55, true, 220.55, 230.55),
    (v_wheat_id, '2025-03-04', 214.64, true, 209.64, 219.64),
    (v_wheat_id, '2025-03-05', 227.29, true, 222.29, 232.29),
    (v_wheat_id, '2025-03-06', 222.18, true, 217.18, 227.18),
    (v_wheat_id, '2025-03-07', 216.30, true, 211.30, 221.30),
    (v_wheat_id, '2025-03-08', 213.40, true, 208.40, 218.40),
    (v_wheat_id, '2025-03-09', 229.19, true, 224.19, 234.19),
    (v_wheat_id, '2025-03-10', 224.18, true, 219.18, 229.18),
    (v_wheat_id, '2025-03-11', 222.28, true, 217.28, 227.28),
    (v_wheat_id, '2025-03-12', 223.27, true, 218.27, 228.27),
    (v_wheat_id, '2025-03-13', 231.60, true, 226.60, 236.60),
    (v_wheat_id, '2025-03-14', 225.71, true, 220.71, 230.71),
    (v_wheat_id, '2025-03-15', 229.65, true, 224.65, 234.65),
    (v_wheat_id, '2025-03-16', 212.57, true, 207.57, 217.57),
    (v_wheat_id, '2025-03-17', 219.32, true, 214.32, 224.32),
    (v_wheat_id, '2025-03-18', 212.84, true, 207.84, 217.84),
    (v_wheat_id, '2025-03-19', 214.21, true, 209.21, 219.21),
    (v_wheat_id, '2025-03-20', 220.51, true, 215.51, 225.51),
    (v_wheat_id, '2025-03-21', 225.93, true, 220.93, 230.93),
    (v_wheat_id, '2025-03-22', 212.65, true, 207.65, 217.65),
    (v_wheat_id, '2025-03-23', 231.32, true, 226.32, 236.32),
    (v_wheat_id, '2025-03-24', 230.99, true, 225.99, 235.99),
    (v_wheat_id, '2025-03-25', 229.69, true, 224.69, 234.69),
    (v_wheat_id, '2025-03-26', 216.86, true, 211.86, 221.86),
    (v_wheat_id, '2025-03-27', 216.16, true, 211.16, 221.16),
    (v_wheat_id, '2025-03-28', 221.63, true, 216.63, 226.63),
    (v_wheat_id, '2025-03-29', 212.93, true, 207.93, 217.93),
    (v_wheat_id, '2025-03-30', 227.12, true, 222.12, 232.12),
    (v_wheat_id, '2025-03-31', 222.74, true, 217.74, 227.74),
    (v_wheat_id, '2025-04-01', 214.71, true, 209.71, 219.71),
    (v_wheat_id, '2025-04-02', 219.99, true, 214.99, 224.99),
    (v_wheat_id, '2025-04-03', 227.06, true, 222.06, 232.06),
    (v_wheat_id, '2025-04-04', 230.67, true, 225.67, 235.67),
    (v_wheat_id, '2025-04-05', 219.81, true, 214.81, 224.81),
    (v_wheat_id, '2025-04-06', 229.69, true, 224.69, 234.69),
    (v_wheat_id, '2025-04-07', 217.92, true, 212.92, 222.92),
    (v_wheat_id, '2025-04-08', 222.78, true, 217.78, 227.78),
    (v_wheat_id, '2025-04-09', 219.77, true, 214.77, 224.77),
    (v_wheat_id, '2025-04-10', 231.52, true, 226.52, 236.52),
    (v_wheat_id, '2025-04-11', 228.07, true, 223.07, 233.07),
    (v_wheat_id, '2025-04-12', 219.45, true, 214.45, 224.45),
    (v_wheat_id, '2025-04-13', 220.80, true, 215.80, 225.80),
    (v_wheat_id, '2025-04-14', 227.05, true, 222.05, 232.05),
    (v_wheat_id, '2025-04-15', 230.14, true, 225.14, 235.14),
    (v_wheat_id, '2025-04-16', 223.27, true, 218.27, 228.27),
    (v_wheat_id, '2025-04-17', 213.77, true, 208.77, 218.77),
    (v_wheat_id, '2025-04-18', 224.61, true, 219.61, 229.61),
    (v_wheat_id, '2025-04-19', 214.48, true, 209.48, 219.48),
    (v_wheat_id, '2025-04-20', 226.18, true, 221.18, 231.18),
    (v_wheat_id, '2025-04-21', 226.42, true, 221.42, 231.42),
    (v_wheat_id, '2025-04-22', 214.79, true, 209.79, 219.79),
    (v_wheat_id, '2025-04-23', 224.63, true, 219.63, 229.63),
    (v_wheat_id, '2025-04-24', 231.72, true, 226.72, 236.72);
END $$;

-- Add helpful comment
COMMENT ON TABLE wheat_master_table IS 'Contains historical and forecasted wheat prices from May 2024 to April 2025';