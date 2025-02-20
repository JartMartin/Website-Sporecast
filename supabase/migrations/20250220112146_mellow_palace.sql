-- Create catalog_commodities table
CREATE TABLE IF NOT EXISTS catalog_commodities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  market_code text NOT NULL,
  exchange text NOT NULL,
  status text NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'coming-soon', 'in-queue')),
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create catalog_requests table
CREATE TABLE IF NOT EXISTS catalog_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  company text,
  email text NOT NULL,
  phone text,
  commodity_name text NOT NULL,
  market_code text NOT NULL,
  exchange text NOT NULL,
  details text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create catalog_notifications table
CREATE TABLE IF NOT EXISTS catalog_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  company text NOT NULL,
  email text NOT NULL,
  phone text,
  commodity_id uuid REFERENCES catalog_commodities(id) ON DELETE CASCADE NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'notified', 'cancelled')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE catalog_commodities ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalog_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalog_notifications ENABLE ROW LEVEL SECURITY;

-- Create policies for catalog_commodities
CREATE POLICY "Commodities are viewable by everyone"
  ON catalog_commodities FOR SELECT
  TO public
  USING (true);

-- Create policies for catalog_requests
CREATE POLICY "Requests are insertable by anyone"
  ON catalog_requests FOR INSERT
  TO public
  WITH CHECK (true);

-- Create policies for catalog_notifications
CREATE POLICY "Notifications are insertable by anyone"
  ON catalog_notifications FOR INSERT
  TO public
  WITH CHECK (true);

-- Create indexes for better performance
CREATE INDEX idx_catalog_commodities_status ON catalog_commodities(status);
CREATE INDEX idx_catalog_requests_status ON catalog_requests(status);
CREATE INDEX idx_catalog_notifications_status ON catalog_notifications(status);

-- Insert initial commodity data
INSERT INTO catalog_commodities (name, category, market_code, exchange, status, description) VALUES
  ('Milling Wheat / Blé de Meunerie', 'Cereals', 'EBM', 'Euronext', 'available', 'European milling wheat futures'),
  ('Corn / Maize', 'Cereals', 'ZC', 'Chicago Mercantile Exchange (CME)', 'available', 'Corn futures contract'),
  ('Barley', 'Cereals', 'BAR', 'Euronext', 'coming-soon', 'European barley futures'),
  ('Oats', 'Cereals', 'ZO', 'Chicago Mercantile Exchange (CME)', 'in-queue', 'Oats futures contract'),
  ('Soybean', 'Oilseeds', 'ZS', 'Chicago Mercantile Exchange (CME)', 'coming-soon', 'Soybean futures contract');

-- Add helpful comments
COMMENT ON TABLE catalog_commodities IS 'Available and upcoming commodities in the catalog';
COMMENT ON TABLE catalog_requests IS 'Requests for new commodities to be added to the catalog';
COMMENT ON TABLE catalog_notifications IS 'Notification subscriptions for upcoming commodities';

COMMENT ON COLUMN catalog_commodities.status IS 'Current status of the commodity (available, coming-soon, in-queue)';
COMMENT ON COLUMN catalog_requests.status IS 'Status of the commodity request (pending, approved, rejected)';
COMMENT ON COLUMN catalog_notifications.status IS 'Status of the notification subscription (active, notified, cancelled)';