-- Add Teams meeting fields to scheduled_meetings
ALTER TABLE scheduled_meetings
ADD COLUMN teams_link text,
ADD COLUMN calendar_event_id text,
ADD COLUMN reminder_sent boolean DEFAULT false;

-- Add helpful comments
COMMENT ON COLUMN scheduled_meetings.teams_link IS 'Microsoft Teams meeting link';
COMMENT ON COLUMN scheduled_meetings.calendar_event_id IS 'Calendar event identifier for updates';
COMMENT ON COLUMN scheduled_meetings.reminder_sent IS 'Whether the 30-minute reminder has been sent';