-- Add unique constraint for meeting slots
ALTER TABLE scheduled_meetings
ADD CONSTRAINT unique_meeting_slot UNIQUE (meeting_date, meeting_time);

-- Add helpful comment
COMMENT ON CONSTRAINT unique_meeting_slot ON scheduled_meetings IS 'Ensures no double bookings for the same time slot';