-- Add new columns to waitlist_entries table
ALTER TABLE waitlist_entries
ADD COLUMN full_name text NOT NULL,
ADD COLUMN notify_launch boolean DEFAULT true,
ADD COLUMN notify_releases boolean DEFAULT false;

-- Add helpful comments
COMMENT ON COLUMN waitlist_entries.full_name IS 'Full name of the interested user';
COMMENT ON COLUMN waitlist_entries.notify_launch IS 'Whether to notify when platform launches';
COMMENT ON COLUMN waitlist_entries.notify_releases IS 'Whether to notify about new commodity releases';