/*
  # Commodities and Forecasts Schema

  1. New Tables
    - `commodities`
      - `id` (uuid, primary key)
      - `name` (text)
      - `symbol` (text)
      - `created_at` (timestamp with time zone)
      - `updated_at` (timestamp with time zone)
    
    - `forecasts`
      - `id` (uuid, primary key)
      - `commodity_id` (uuid, references commodities)
      - `user_id` (uuid, references auth.users)
      - `price` (decimal)
      - `confidence` (decimal)
      - `forecast_date` (date)
      - `created_at` (timestamp with time zone)

  2. Security
    - Enable RLS on both tables
    - Add policies for:
      - Public read access to commodities
      - Authenticated users can read their own forecasts
*/

-- Commodities table
CREATE TABLE IF NOT EXISTS commodities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  symbol text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Forecasts table
CREATE TABLE IF NOT EXISTS forecasts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  price decimal NOT NULL,
  confidence decimal NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
  forecast_date date NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE commodities ENABLE ROW LEVEL SECURITY;
ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;

-- Policies for commodities
CREATE POLICY "Commodities are viewable by everyone"
  ON commodities
  FOR SELECT
  TO public
  USING (true);

-- Policies for forecasts
CREATE POLICY "Users can view own forecasts"
  ON forecasts
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own forecasts"
  ON forecasts
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Insert initial commodity data
INSERT INTO commodities (name, symbol) VALUES
  ('Wheat', 'WHEAT'),
  ('Corn', 'CORN'),
  ('Soybeans', 'SOYB')
ON CONFLICT (symbol) DO NOTHING;