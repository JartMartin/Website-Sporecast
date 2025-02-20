import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { MainNav } from "@/components/navigation/main-nav";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Calendar } from "@/components/ui/calendar";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/lib/supabase";
import { Coffee, CalendarDays, Building2, User2, Clock, ArrowRight, Languages } from "lucide-react";
import { cn } from "@/lib/utils";
import { Footer } from "@/components/landing/footer";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";

// Only allow Tuesdays and Fridays
const isDateAvailable = (date: Date) => {
  const day = date.getDay();
  return day === 2 || day === 5; // 2 is Tuesday, 5 is Friday
};

// Available time slots
const timeSlots = [
  "11:00", "14:00", "15:00", "16:00"
];

// Language options
const languages = [
  { value: "en", label: "English" },
  { value: "nl", label: "Dutch" }
];

interface BookedSlot {
  meeting_time: string;
}

interface ConfirmationDialogProps {
  open: boolean;
  onClose: () => void;
  meetingDetails: {
    date: Date;
    time: string;
    meetLink: string;
  };
}

function ConfirmationDialog({ open, onClose, meetingDetails }: ConfirmationDialogProps) {
  const addToCalendar = (type: 'google' | 'outlook' | 'ical') => {
    const startTime = new Date(meetingDetails.date);
    const [hours, minutes] = meetingDetails.time.split(':');
    startTime.setHours(parseInt(hours), parseInt(minutes));
    
    const endTime = new Date(startTime);
    endTime.setMinutes(endTime.getMinutes() + 15);

    const event = {
      title: 'Sporecast Online Coffee Meeting',
      description: `Google Meet Link: ${meetingDetails.meetLink}\n\nJoin us for a friendly chat about how Sporecast can help optimize your procurement strategy.`,
      startTime: startTime.toISOString(),
      endTime: endTime.toISOString(),
      location: meetingDetails.meetLink
    };

    let calendarUrl = '';

    switch (type) {
      case 'google':
        calendarUrl = `https://calendar.google.com/calendar/render?action=TEMPLATE&text=${encodeURIComponent(event.title)}&dates=${startTime.toISOString().replace(/[-:]/g, '').split('.')[0]}Z/${endTime.toISOString().replace(/[-:]/g, '').split('.')[0]}Z&details=${encodeURIComponent(event.description)}&location=${encodeURIComponent(event.location)}&sprop=&sprop=name:`;
        break;
      case 'outlook':
        calendarUrl = `https://outlook.live.com/calendar/0/deeplink/compose?subject=${encodeURIComponent(event.title)}&startdt=${startTime.toISOString()}&enddt=${endTime.toISOString()}&body=${encodeURIComponent(event.description)}&location=${encodeURIComponent(event.location)}`;
        break;
      case 'ical':
        // Generate iCal file content
        const icalContent = [
          'BEGIN:VCALENDAR',
          'VERSION:2.0',
          'BEGIN:VEVENT',
          `DTSTART:${startTime.toISOString().replace(/[-:]/g, '').split('.')[0]}Z`,
          `DTEND:${endTime.toISOString().replace(/[-:]/g, '').split('.')[0]}Z`,
          `SUMMARY:${event.title}`,
          `DESCRIPTION:${event.description.replace(/\n/g, '\\n')}`,
          `LOCATION:${event.location}`,
          'BEGIN:VALARM',
          'TRIGGER:-PT15M',
          'ACTION:DISPLAY',
          'DESCRIPTION:Reminder',
          'END:VALARM',
          'END:VEVENT',
          'END:VCALENDAR'
        ].join('\n');

        const blob = new Blob([icalContent], { type: 'text/calendar;charset=utf-8' });
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.setAttribute('download', 'sporecast-meeting.ics');
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        window.URL.revokeObjectURL(url);
        return;
    }

    window.open(calendarUrl, '_blank');
  };

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Meeting Scheduled Successfully!</DialogTitle>
        </DialogHeader>
        <div className="space-y-6 pt-4">
          <div className="space-y-2">
            <h4 className="font-medium">Google Meet Link</h4>
            <div className="p-3 bg-muted rounded-lg">
              <a 
                href={meetingDetails.meetLink} 
                target="_blank" 
                rel="noopener noreferrer"
                className="text-sm text-teal-600 hover:text-teal-700 break-all"
              >
                {meetingDetails.meetLink}
              </a>
            </div>
          </div>

          <div className="space-y-2">
            <h4 className="font-medium">Add to Calendar</h4>
            <div className="grid grid-cols-3 gap-2">
              <Button 
                variant="outline" 
                className="w-full text-sm"
                onClick={() => addToCalendar('google')}
              >
                Google
              </Button>
              <Button 
                variant="outline"
                className="w-full text-sm"
                onClick={() => addToCalendar('outlook')}
              >
                Outlook
              </Button>
              <Button 
                variant="outline"
                className="w-full text-sm"
                onClick={() => addToCalendar('ical')}
              >
                iCal
              </Button>
            </div>
          </div>

          <p className="text-sm text-muted-foreground">
            A confirmation email has been sent to your email address with these details.
          </p>
        </div>
      </DialogContent>
    </Dialog>
  );
}

export function SchedulePage() {
  const [formData, setFormData] = useState({
    fullName: "",
    email: "",
    company: "",
    date: null as Date | null,
    timeSlot: "",
    language: "en" // Default to English
  });
  const [loading, setLoading] = useState(false);
  const [loadingSlots, setLoadingSlots] = useState(false);
  const [bookedSlots, setBookedSlots] = useState<string[]>([]);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [meetingDetails, setMeetingDetails] = useState<{
    date: Date;
    time: string;
    meetLink: string;
  } | null>(null);
  const navigate = useNavigate();
  const { toast } = useToast();

  // Fetch booked slots when date changes
  useEffect(() => {
    const fetchBookedSlots = async () => {
      if (!formData.date) {
        setBookedSlots([]);
        return;
      }

      setLoadingSlots(true);
      try {
        const { data, error } = await supabase
          .from('scheduled_meetings')
          .select('meeting_time')
          .eq('meeting_date', formData.date.toISOString().split('T')[0])
          .eq('status', 'scheduled');

        if (error) throw error;

        setBookedSlots(data?.map(slot => slot.meeting_time) || []);
      } catch (error) {
        console.error('Error fetching booked slots:', error);
        toast({
          title: "Error",
          description: "Failed to load available time slots. Please try again.",
          variant: "destructive",
        });
      } finally {
        setLoadingSlots(false);
      }
    };

    fetchBookedSlots();
  }, [formData.date]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (!formData.date || !formData.timeSlot) {
        throw new Error('Please select both date and time');
      }

      // Generate Google Meet link
      const meetLink = `https://meet.google.com/${Math.random().toString(36).substring(2, 15)}`;

      // Store meeting in Supabase
      const { error } = await supabase
        .from('scheduled_meetings')
        .insert({
          full_name: formData.fullName.trim(),
          email: formData.email.trim(),
          company: formData.company.trim() || null,
          language: formData.language,
          meeting_date: formData.date.toISOString().split('T')[0],
          meeting_time: formData.timeSlot,
          meet_link: meetLink,
          status: 'scheduled'
        });

      if (error) {
        // Handle unique constraint violation
        if (error.code === '23505') {
          throw new Error('This time slot has just been booked. Please select another time.');
        }
        throw error;
      }

      // Set meeting details for confirmation dialog
      setMeetingDetails({
        date: formData.date,
        time: formData.timeSlot,
        meetLink
      });

      // Show confirmation dialog
      setShowConfirmation(true);
    } catch (error: any) {
      console.error('Error scheduling meeting:', error);
      toast({
        title: "Error",
        description: error.message || "Failed to schedule the meeting. Please try again.",
        variant: "destructive",
      });

      // If it was a duplicate booking, refresh the slots
      if (error.message.includes('time slot has just been booked')) {
        const date = formData.date;
        setFormData(prev => ({ ...prev, timeSlot: '' })); // Reset time slot
        // Re-trigger the useEffect by updating the date
        setFormData(prev => ({ ...prev, date: null }));
        setTimeout(() => setFormData(prev => ({ ...prev, date })), 0);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <MainNav />

      <main className="flex-1 py-12 md:py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Header Section */}
          <div className="text-center mb-12">
            <div className="inline-flex items-center justify-center gap-2 mb-6">
              <div className="relative">
                <div className="absolute -inset-1 rounded-full bg-gradient-to-br from-teal-500 to-emerald-500 opacity-25 blur" />
                <div className="relative h-14 w-14 rounded-full bg-gradient-to-br from-teal-500 to-emerald-500 flex items-center justify-center shadow-lg">
                  <Coffee className="h-7 w-7 text-white" />
                </div>
              </div>
            </div>
            <h1 className="text-4xl font-bold tracking-tight mb-4">
              Let's connect!
            </h1>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            Schedule a 15-minute introductory meeting to explore our platform. We'll guide you through our data-driven features, demonstrate actionable insights, and answer any questions or concerns you may have. This is your opportunity to learn more and see how we can support your goals!
            </p>
          </div>

          <Card className="p-6 md:p-8">
            <form onSubmit={handleSubmit} className="space-y-8">
              {/* Contact Information */}
              <div className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <Label htmlFor="fullName">Full Name *</Label>
                    <div className="relative">
                      <User2 className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        id="fullName"
                        placeholder="Enter your full name"
                        value={formData.fullName}
                        onChange={(e) => setFormData(prev => ({ ...prev, fullName: e.target.value }))}
                        className="pl-9"
                        required
                      />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="email">Email Address *</Label>
                    <Input
                      id="email"
                      type="email"
                      placeholder="Enter your email"
                      value={formData.email}
                      onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
                      required
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <Label htmlFor="company">Company Name</Label>
                    <div className="relative">
                      <Building2 className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        id="company"
                        placeholder="Enter your company name"
                        value={formData.company}
                        onChange={(e) => setFormData(prev => ({ ...prev, company: e.target.value }))}
                        className="pl-9"
                      />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="language" className="flex items-center gap-2">
                      <Languages className="h-4 w-4" />
                      Preferred Language *
                    </Label>
                    <Select
                      value={formData.language}
                      onValueChange={(value) => setFormData(prev => ({ ...prev, language: value }))}
                      required
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select your preferred language" />
                      </SelectTrigger>
                      <SelectContent>
                        {languages.map((language) => (
                          <SelectItem key={language.value} value={language.value}>
                            {language.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </div>

              {/* Meeting Time Selection */}
              <div className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                  <div className="space-y-2">
                    <Label className="flex items-center gap-2">
                      <CalendarDays className="h-4 w-4" />
                      Select Date *
                    </Label>
                    <Calendar
                      mode="single"
                      selected={formData.date}
                      onSelect={(date) => {
                        setFormData(prev => ({ 
                          ...prev, 
                          date,
                          timeSlot: "" // Reset time slot when date changes
                        }));
                      }}
                      disabled={(date) => !isDateAvailable(date) || date < new Date()}
                      className="rounded-lg border shadow-sm"
                      classNames={{
                        day_selected: "bg-teal-600 text-white hover:bg-teal-600 hover:text-white focus:bg-teal-600 focus:text-white",
                        day_today: "bg-gray-100 text-gray-900",
                      }}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="flex items-center gap-2">
                      <Clock className="h-4 w-4" />
                      Select Time *
                    </Label>
                    {loadingSlots ? (
                      <div className="h-[200px] flex items-center justify-center">
                        <div className="flex items-center gap-2 text-sm text-muted-foreground">
                          <Clock className="h-4 w-4 animate-spin" />
                          Loading available times...
                        </div>
                      </div>
                    ) : (
                      <div className="grid grid-cols-2 gap-2">
                        {timeSlots.map((slot) => {
                          const isBooked = bookedSlots.includes(slot);
                          return (
                            <Button
                              key={slot}
                              type="button"
                              variant={formData.timeSlot === slot ? "default" : "outline"}
                              className={cn(
                                "justify-start gap-2 h-12",
                                formData.timeSlot === slot && "bg-teal-600 hover:bg-teal-700",
                                isBooked && "bg-gray-100 hover:bg-gray-100 cursor-not-allowed opacity-60"
                              )}
                              onClick={() => {
                                if (!isBooked) {
                                  setFormData(prev => ({ ...prev, timeSlot: slot }));
                                }
                              }}
                              disabled={!formData.date || isBooked}
                            >
                              <div className="flex items-center gap-2 w-full">
                                <Clock className="h-4 w-4" />
                                <span>{slot}</span>
                                {isBooked && (
                                  <span className="ml-auto text-xs font-medium text-gray-500">
                                    Booked
                                  </span>
                                )}
                              </div>
                            </Button>
                          );
                        })}
                      </div>
                    )}
                    {formData.date && !loadingSlots && bookedSlots.length === timeSlots.length && (
                      <p className="text-sm text-red-500 mt-2">
                        No time slots available for this date. Please select another date.
                      </p>
                    )}
                  </div>
                </div>

                <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 text-sm text-amber-800">
                  <p className="font-medium mb-1">Availability Note:</p>
                  <p>
                    Online coffee meetings are available on Tuesdays and Fridays. On other days, we're focused on optimizing our models and adding more food commodities to ensure you have the best tools for decision-making.
                  </p>
                </div>
              </div>

              <Button
                type="submit"
                size="lg"
                className="w-full"
                disabled={loading || !formData.date || !formData.timeSlot}
              >
                {loading ? (
                  "Scheduling..."
                ) : (
                  <span className="flex items-center gap-2">
                    Schedule Meeting
                    <ArrowRight className="h-4 w-4" />
                  </span>
                )}
              </Button>
            </form>
          </Card>
        </div>
      </main>

      <Footer />

      {/* Confirmation Dialog */}
      {meetingDetails && (
        <ConfirmationDialog
          open={showConfirmation}
          onClose={() => {
            setShowConfirmation(false);
            navigate('/', { replace: true });
          }}
          meetingDetails={meetingDetails}
        />
      )}
    </div>
  );
}

export default SchedulePage;