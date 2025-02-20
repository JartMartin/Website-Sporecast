// Calendar Types
export interface CalendarEvent {
  title: string;
  description: string;
  startTime: Date;
  endTime: Date;
  location: string;
}

// Meeting Types
export interface MeetingDetails {
  full_name: string;
  email: string;
  company?: string;
  language: string;
  meeting_date: string;
  meeting_time: string;
  meet_link?: string;
}

// UI Types
export interface ToastProps {
  title?: string;
  description?: string;
  variant?: 'default' | 'destructive';
}