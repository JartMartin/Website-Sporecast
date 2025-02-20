-- Create waitlist_entries table
CREATE TABLE waitlist_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  company text,
  interested_commodities text,
  market_codes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE waitlist_entries ENABLE ROW LEVEL SECURITY;

-- Create policy for inserting entries
CREATE POLICY "Waitlist entries are insertable by anyone"
  ON waitlist_entries FOR INSERT
  TO public
  WITH CHECK (true);

-- Create index for better performance
CREATE INDEX idx_waitlist_entries_email ON waitlist_entries(email);

-- Add helpful comments
COMMENT ON TABLE waitlist_entries IS 'Stores potential customer information for the waitlist';
COMMENT ON COLUMN waitlist_entries.email IS 'Email address of the interested user';
COMMENT ON COLUMN waitlist_entries.company IS 'Optional company name';
COMMENT ON COLUMN waitlist_entries.interested_commodities IS 'List of commodities they are interested in';
COMMENT ON COLUMN waitlist_entries.market_codes IS 'Specific market codes they are interested in';