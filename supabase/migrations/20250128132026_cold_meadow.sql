-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can schedule a meeting" ON scheduled_meetings;
DROP POLICY IF EXISTS "Admins can view meetings" ON scheduled_meetings;

-- Create new policies
CREATE POLICY "Anyone can schedule a meeting"
  ON scheduled_meetings FOR INSERT
  TO public -- Changed from authenticated to public
  WITH CHECK (true);

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

-- Add helpful comments
COMMENT ON POLICY "Anyone can schedule a meeting" ON scheduled_meetings IS 'Allows anyone to schedule a meeting, even if not authenticated';
COMMENT ON POLICY "Admins can view meetings" ON scheduled_meetings IS 'Only board management can view scheduled meetings';