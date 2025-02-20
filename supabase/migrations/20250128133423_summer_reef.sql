-- Drop existing table if it exists
DROP TABLE IF EXISTS scheduled_meetings CASCADE;

-- Create scheduled_meetings table
CREATE TABLE scheduled_meetings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  email text NOT NULL,
  company text,
  language text NOT NULL DEFAULT 'en',
  meeting_date date NOT NULL,
  meeting_time text NOT NULL,
  status text NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT unique_meeting_slot UNIQUE (meeting_date, meeting_time, status)
);

-- Enable RLS
ALTER TABLE scheduled_meetings ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can schedule a meeting"
  ON scheduled_meetings FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can view booked slots"
  ON scheduled_meetings FOR SELECT
  TO public
  USING (status = 'scheduled');

-- Create indexes for better performance
CREATE INDEX idx_scheduled_meetings_slot 
ON scheduled_meetings(meeting_date, meeting_time, status);

-- Add helpful comments
COMMENT ON TABLE scheduled_meetings IS 'Stores scheduled online coffee meetings';
COMMENT ON COLUMN scheduled_meetings.language IS 'Preferred language for the meeting (en/nl)';
COMMENT ON COLUMN scheduled_meetings.meeting_time IS 'Time slot for the meeting (e.g., "10:00")';
COMMENT ON COLUMN scheduled_meetings.status IS 'Current status of the meeting';