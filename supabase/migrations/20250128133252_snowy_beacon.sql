-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can schedule a meeting" ON scheduled_meetings;
DROP POLICY IF EXISTS "Admins can view meetings" ON scheduled_meetings;

-- Create new policies
CREATE POLICY "Anyone can schedule a meeting"
  ON scheduled_meetings FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can view meeting slots"
  ON scheduled_meetings FOR SELECT
  TO public
  USING (true);

-- Add index for meeting slot lookups
CREATE INDEX IF NOT EXISTS idx_scheduled_meetings_slot 
ON scheduled_meetings(meeting_date, meeting_time, status);

-- Add helpful comments
COMMENT ON TABLE scheduled_meetings IS 'Stores scheduled online coffee meetings';
COMMENT ON POLICY "Anyone can schedule a meeting" ON scheduled_meetings IS 'Allows anyone to schedule a meeting';
COMMENT ON POLICY "Anyone can view meeting slots" ON scheduled_meetings IS 'Allows checking slot availability';