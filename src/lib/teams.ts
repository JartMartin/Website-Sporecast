import { Client } from "@microsoft/microsoft-graph-client";
import { AuthenticationProvider } from "@microsoft/microsoft-graph-client";

// Configure your Azure AD credentials
const config = {
  clientId: process.env.MICROSOFT_CLIENT_ID,
  clientSecret: process.env.MICROSOFT_CLIENT_SECRET,
  tenantId: process.env.MICROSOFT_TENANT_ID,
  organizerEmail: process.env.TEAMS_ORGANIZER_EMAIL // The email that will host the meetings
};

class TeamsMeetingService {
  private client: Client;

  constructor() {
    // Initialize Graph client with your auth provider
    this.client = Client.init({
      authProvider: async (done) => {
        // Implement token acquisition here
        // This is where you'll use your Azure AD credentials
        done(null, "access_token");
      }
    });
  }

  async createMeeting(details: {
    subject: string;
    startTime: Date;
    endTime: Date;
    attendeeEmail: string;
  }) {
    try {
      const meeting = await this.client.api('/users/' + config.organizerEmail + '/onlineMeetings')
        .post({
          startDateTime: details.startTime.toISOString(),
          endDateTime: details.endTime.toISOString(),
          subject: details.subject,
          participants: {
            attendees: [
              {
                emailAddress: {
                  address: details.attendeeEmail
                }
              }
            ]
          }
        });

      return {
        joinUrl: meeting.joinUrl,
        meetingId: meeting.id
      };
    } catch (error) {
      console.error('Error creating Teams meeting:', error);
      throw error;
    }
  }
}

export const teamsMeetingService = new TeamsMeetingService();