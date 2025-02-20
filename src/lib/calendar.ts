import { formatISO } from 'date-fns';

export function generateICSFile(
  startTime: Date,
  endTime: Date,
  subject: string,
  description: string,
  location: string
): string {
  const event = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'BEGIN:VEVENT',
    `DTSTART:${formatISO(startTime, { format: 'basic' }).replace(/[-:]/g, '')}`,
    `DTEND:${formatISO(endTime, { format: 'basic' }).replace(/[-:]/g, '')}`,
    `SUMMARY:${subject}`,
    `DESCRIPTION:${description.replace(/\n/g, '\\n')}`,
    `LOCATION:${location}`,
    'BEGIN:VALARM',
    'TRIGGER:-PT30M',
    'ACTION:DISPLAY',
    'DESCRIPTION:Reminder',
    'END:VALARM',
    'END:VEVENT',
    'END:VCALENDAR'
  ].join('\n');

  return event;
}

export function generateGoogleCalendarURL(
  startTime: Date,
  endTime: Date,
  subject: string,
  description: string,
  location: string
): string {
  const params = new URLSearchParams({
    action: 'TEMPLATE',
    text: subject,
    details: description,
    location,
    dates: `${formatISO(startTime, { format: 'basic' }).split('+')[0]}/${
      formatISO(endTime, { format: 'basic' }).split('+')[0]
    }`,
  });

  return `https://calendar.google.com/calendar/render?${params.toString()}`;
}

export function generateMeetLink(): string {
  // Generate a random meeting ID
  const meetingId = Math.random().toString(36).substring(2, 15);
  return `https://meet.google.com/${meetingId}`;
}