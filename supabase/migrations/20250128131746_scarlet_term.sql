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
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE scheduled_meetings ENABLE ROW LEVEL SECURITY;

-- Create policy for inserting meetings (anyone can schedule)
CREATE POLICY "Anyone can schedule a meeting"
  ON scheduled_meetings FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Create policy for viewing meetings (admin only)
CREATE POLICY "Admins can view meetings"
  ON scheduled_meetings FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
      AND role = 'board_management'
    )
  );

-- Create indexes for better performance
CREATE INDEX idx_scheduled_meetings_date ON scheduled_meetings(meeting_date);
CREATE INDEX idx_scheduled_meetings_status ON scheduled_meetings(status);

-- Add helpful comments
COMMENT ON TABLE scheduled_meetings IS 'Stores scheduled online coffee meetings';
COMMENT ON COLUMN scheduled_meetings.language IS 'Preferred language for the meeting (en/nl)';
COMMENT ON COLUMN scheduled_meetings.meeting_time IS 'Time slot for the meeting (e.g., "10:00")';
COMMENT ON COLUMN scheduled_meetings.status IS 'Current status of the meeting';