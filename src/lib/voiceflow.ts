import { v4 as uuidv4 } from 'uuid';

// Voiceflow API types
export interface VoiceflowMessage {
  type: 'text' | 'choice' | 'end';
  payload: {
    message?: string;
    choices?: string[];
    data?: any;
  };
}

export interface VoiceflowResponse {
  messages: VoiceflowMessage[];
  state: any;
}

// Mock conversation flows
const FLOWS = {
  GREETING: {
    messages: [
      {
        type: 'text',
        payload: {
          message: "Hi! I'm Spora, your AI assistant for commodity forecasting. I can help you with:"
        }
      },
      {
        type: 'choice',
        payload: {
          choices: [
            "Understanding price forecasts",
            "Setting up alerts",
            "Analyzing market trends",
            "Learning about our methodology"
          ]
        }
      }
    ]
  },
  PRICE_FORECASTS: {
    messages: [
      {
        type: 'text',
        payload: {
          message: "Our AI models analyze over 130,000 variables daily to generate accurate price forecasts. Would you like to:"
        }
      },
      {
        type: 'choice',
        payload: {
          choices: [
            "View current wheat forecasts",
            "Compare with historical data",
            "Understand confidence intervals",
            "Set price alerts"
          ]
        }
      }
    ]
  },
  METHODOLOGY: {
    messages: [
      {
        type: 'text',
        payload: {
          message: "Our forecasting methodology combines multiple advanced techniques:"
        }
      },
      {
        type: 'text',
        payload: {
          message: "1. Neural Networks: Deep learning models trained on 20+ years of data\n2. Market Analysis: Real-time processing of market indicators\n3. Climate Data: Integration of weather patterns and seasonal trends\n4. Technical Analysis: Advanced pattern recognition"
        }
      },
      {
        type: 'choice',
        payload: {
          choices: [
            "Learn about accuracy rates",
            "View sample forecasts",
            "Understand data sources"
          ]
        }
      }
    ]
  },
  ALERTS: {
    messages: [
      {
        type: 'text',
        payload: {
          message: "You can set up custom alerts for:"
        }
      },
      {
        type: 'text',
        payload: {
          message: "• Price thresholds\n• Percentage changes\n• Volatility levels\n• Trend reversals"
        }
      },
      {
        type: 'choice',
        payload: {
          choices: [
            "Set up a new alert",
            "View current alerts",
            "Learn more about alert types"
          ]
        }
      }
    ]
  }
};

// Voiceflow session state
interface VoiceflowState {
  sessionId: string;
  context: {
    lastFlow?: keyof typeof FLOWS;
    userPreferences?: {
      commodity?: string;
      timeframe?: string;
    };
  };
}

// Voiceflow API client
export class VoiceflowClient {
  private apiKey: string;
  private versionID: string;
  private baseURL: string;
  private sessions: Map<string, VoiceflowState>;

  constructor(config: { apiKey: string; versionID: string; baseURL?: string }) {
    this.apiKey = config.apiKey;
    this.versionID = config.versionID;
    this.baseURL = config.baseURL || 'https://general-runtime.voiceflow.com';
    this.sessions = new Map();
  }

  public createSession(): string {
    const sessionId = uuidv4();
    this.sessions.set(sessionId, {
      sessionId,
      context: {}
    });
    return sessionId;
  }

  public async interact(sessionId: string, request: string): Promise<VoiceflowResponse> {
    const session = this.sessions.get(sessionId);
    if (!session) throw new Error('Invalid session');

    // Process input and determine appropriate flow
    const response = this.processInput(request.toLowerCase(), session);
    return response;
  }

  private processInput(input: string, session: VoiceflowState): VoiceflowResponse {
    // Check for greetings
    if (input.match(/^(hi|hello|hey|help)/i)) {
      session.context.lastFlow = 'GREETING';
      return { messages: FLOWS.GREETING.messages, state: session.context };
    }

    // Check for forecast-related queries
    if (input.includes('forecast') || input.includes('price') || input.includes('predict')) {
      session.context.lastFlow = 'PRICE_FORECASTS';
      return { messages: FLOWS.PRICE_FORECASTS.messages, state: session.context };
    }

    // Check for methodology questions
    if (input.includes('how') || input.includes('method') || input.includes('work')) {
      session.context.lastFlow = 'METHODOLOGY';
      return { messages: FLOWS.METHODOLOGY.messages, state: session.context };
    }

    // Check for alert-related queries
    if (input.includes('alert') || input.includes('notify') || input.includes('warn')) {
      session.context.lastFlow = 'ALERTS';
      return { messages: FLOWS.ALERTS.messages, state: session.context };
    }

    // Handle choices from previous flows
    if (session.context.lastFlow) {
      const flow = FLOWS[session.context.lastFlow];
      const choices = flow.messages.find(m => m.type === 'choice')?.payload.choices || [];
      
      if (choices.some(choice => input.includes(choice.toLowerCase()))) {
        // Return appropriate follow-up flow
        return this.getFollowUpResponse(input, session);
      }
    }

    // Default response
    return {
      messages: [{
        type: 'text',
        payload: {
          message: "I understand you're interested in commodity markets. Could you please specify what you'd like to know about? You can ask about forecasts, methodology, or alerts."
        }
      }],
      state: session.context
    };
  }

  private getFollowUpResponse(input: string, session: VoiceflowState): VoiceflowResponse {
    // Simulate different follow-up responses based on context
    if (input.includes('accuracy')) {
      return {
        messages: [
          {
            type: 'text',
            payload: {
              message: "Our model achieves:\n• 92% hitrate for confidence intervals\n• 95% accuracy for point predictions\n• 89% accuracy for trend direction"
            }
          },
          {
            type: 'choice',
            payload: {
              choices: [
                "View detailed stats",
                "Compare with benchmarks",
                "Back to main menu"
              ]
            }
          }
        ],
        state: session.context
      };
    }

    if (input.includes('set up')) {
      return {
        messages: [
          {
            type: 'text',
            payload: {
              message: "To set up a new alert, you can:\n1. Go to the Alerts page\n2. Click 'Add Alert'\n3. Choose your conditions\n4. Set your thresholds"
            }
          },
          {
            type: 'choice',
            payload: {
              choices: [
                "Go to Alerts page",
                "Learn more about alerts",
                "Back to main menu"
              ]
            }
          }
        ],
        state: session.context
      };
    }

    // Default follow-up
    return {
      messages: [
        {
          type: 'text',
          payload: {
            message: "Would you like to know more about any specific aspect?"
          }
        },
        {
          type: 'choice',
          payload: {
            choices: [
              "View forecasts",
              "Set up alerts",
              "Learn methodology",
              "Back to main menu"
            ]
          }
        }
      ],
      state: session.context
    };
  }
}

// Create a singleton instance
export const voiceflowClient = new VoiceflowClient({
  apiKey: 'mock-api-key',
  versionID: 'mock-version-id'
});