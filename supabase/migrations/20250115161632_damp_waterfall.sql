/*
  # Portfolio Management System Enhancement
  
  1. Changes
    - Creates user_commodities table for tracking purchased commodities
    - Adds status tracking for commodity access
    - Implements portfolio-based access control
  
  2. Security
    - Enables RLS for all new tables
    - Implements strict access policies
*/

-- Create user_commodities table for tracking purchased commodities
CREATE TABLE IF NOT EXISTS user_commodities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  commodity_id uuid REFERENCES commodities ON DELETE CASCADE NOT NULL,
  purchase_date timestamptz DEFAULT now(),
  status text NOT NULL DEFAULT 'active',
  next_billing_date timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, commodity_id),
  CONSTRAINT valid_status CHECK (status IN ('active', 'cancelled', 'pending_cancellation'))
);

-- Enable RLS
ALTER TABLE user_commodities ENABLE ROW LEVEL SECURITY;

-- Create policies for user_commodities
CREATE POLICY "Users can view own commodities"
  ON user_commodities FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own commodities"
  ON user_commodities FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create function to calculate next billing date
CREATE OR REPLACE FUNCTION calculate_next_billing_date(purchase_date timestamptz)
RETURNS timestamptz AS $$
BEGIN
  RETURN date_trunc('month', purchase_date) + interval '1 month';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create function to handle commodity purchase
CREATE OR REPLACE FUNCTION handle_commodity_purchase()
RETURNS TRIGGER AS $$
BEGIN
  NEW.next_billing_date := calculate_next_billing_date(NEW.purchase_date);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for commodity purchase
CREATE TRIGGER on_commodity_purchase
  BEFORE INSERT ON user_commodities
  FOR EACH ROW
  EXECUTE FUNCTION handle_commodity_purchase();

-- Create indexes for better performance
CREATE INDEX idx_user_commodities_user ON user_commodities(user_id);
CREATE INDEX idx_user_commodities_status ON user_commodities(status);
CREATE INDEX idx_user_commodities_billing ON user_commodities(next_billing_date);

-- Add helpful comments
COMMENT ON TABLE user_commodities IS 'Tracks user commodity purchases and subscription status';
COMMENT ON COLUMN user_commodities.status IS 'Current status of the commodity subscription';
COMMENT ON COLUMN user_commodities.next_billing_date IS 'Date of next billing cycle';