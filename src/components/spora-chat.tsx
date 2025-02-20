import { useState, useEffect, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { X, Send, Sprout } from "lucide-react";
import { cn } from "@/lib/utils";
import { VoiceflowClient, VoiceflowMessage, voiceflowClient } from "@/lib/voiceflow";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

interface Message {
  id: string;
  type: 'user' | 'assistant';
  content: string;
  choices?: string[];
  isLoading?: boolean;
}

export function SporaChat() {
  const [isOpen, setIsOpen] = useState(false);
  const [message, setMessage] = useState("");
  const [messages, setMessages] = useState<Message[]>([]);
  const [showWelcome, setShowWelcome] = useState(true);
  const [hasInteracted, setHasInteracted] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const hasSeenWelcome = localStorage.getItem('spora-welcomed');
    setShowWelcome(!hasSeenWelcome && !hasInteracted);

    if (showWelcome) {
      const timer = setTimeout(() => {
        setShowWelcome(false);
        localStorage.setItem('spora-welcomed', 'true');
      }, 10000);

      return () => clearTimeout(timer);
    }
  }, [hasInteracted, showWelcome]);

  useEffect(() => {
    // Scroll to bottom when messages change
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const initializeChat = () => {
    if (!sessionId) {
      const newSessionId = voiceflowClient.createSession();
      setSessionId(newSessionId);
      
      // Add initial greeting with typing effect
      setIsTyping(true);
      setTimeout(() => {
        setMessages([{
          id: crypto.randomUUID(),
          type: 'assistant',
          content: "Hi! I'm Spora, your AI assistant for commodity forecasting. How can I help you today?",
          choices: [
            "Tell me about price forecasts",
            "Help me set up alerts",
            "Explain your methodology",
            "Show market trends"
          ]
        }]);
        setIsTyping(false);
      }, 1000);
    }
  };

  const simulateTyping = async (content: string): Promise<void> => {
    return new Promise((resolve) => {
      const typingTime = Math.min(content.length * 20, 2000); // Cap at 2 seconds
      setTimeout(resolve, typingTime);
    });
  };

  const handleSend = async () => {
    if (!message.trim()) return;

    // Initialize chat if needed
    if (!sessionId) {
      initializeChat();
    }

    // Add user message
    const userMessage: Message = {
      id: crypto.randomUUID(),
      type: 'user',
      content: message.trim()
    };
    setMessages(prev => [...prev, userMessage]);
    setMessage("");

    // Show typing indicator
    setIsTyping(true);

    try {
      // Get response from Voiceflow
      const response = await voiceflowClient.interact(sessionId!, message.trim());
      
      // Process each message in the response with typing effect
      for (const msg of response.messages) {
        // Simulate typing delay
        await simulateTyping(msg.payload.message || '');
        
        const assistantMessage: Message = {
          id: crypto.randomUUID(),
          type: 'assistant',
          content: msg.payload.message || '',
          choices: msg.type === 'choice' ? msg.payload.choices : undefined
        };
        setMessages(prev => [...prev, assistantMessage]);
      }
    } catch (error) {
      console.error('Error getting response:', error);
      setMessages(prev => [...prev, {
        id: crypto.randomUUID(),
        type: 'assistant',
        content: "I apologize, but I'm having trouble processing your request right now. Please try again later."
      }]);
    } finally {
      setIsTyping(false);
    }
  };

  const handleOpen = () => {
    setIsOpen(true);
    setHasInteracted(true);
    setShowWelcome(false);
    initializeChat();
  };

  return (
    <div className="fixed bottom-6 right-6 z-50">
      {isOpen ? (
        <Card className={cn(
          "w-[350px] h-[500px] flex flex-col shadow-lg",
          "animate-in slide-in-from-bottom-5 duration-300",
          "bg-white/95 backdrop-blur-md rounded-2xl border-neutral-200/80"
        )}>
          {/* Header */}
          <div className="flex items-center justify-between p-3 border-b bg-gradient-to-r from-teal-500 to-emerald-500 rounded-t-2xl">
            <div className="flex items-center gap-2">
              <div className="h-7 w-7 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center">
                <Sprout className="h-4 w-4 text-white" />
              </div>
              <div>
                <h3 className="text-sm font-medium text-white">Spora Assistant</h3>
                <p className="text-[10px] text-white/80">AI-powered help</p>
              </div>
            </div>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setIsOpen(false)}
              className="h-7 w-7 text-white hover:bg-white/20 rounded-full"
            >
              <X className="h-3.5 w-3.5" />
            </Button>
          </div>

          {/* Messages Area */}
          <div className="flex-1 p-3 overflow-y-auto space-y-3 bg-gradient-to-b from-neutral-50/50 to-white">
            {messages.map((msg) => (
              <div key={msg.id} className={cn(
                "flex gap-2",
                msg.type === 'user' && "justify-end"
              )}>
                {msg.type === 'assistant' && (
                  <div className="h-7 w-7 rounded-full bg-gradient-to-br from-teal-400 to-emerald-500 flex items-center justify-center flex-shrink-0 shadow-sm">
                    <Sprout className="h-3.5 w-3.5 text-white" />
                  </div>
                )}
                <div className={cn(
                  "rounded-xl p-2.5 max-w-[85%] shadow-sm border",
                  msg.type === 'assistant' ? "bg-white border-neutral-100" : "bg-teal-500 text-white border-transparent"
                )}>
                  <p className="text-xs leading-relaxed whitespace-pre-line">{msg.content}</p>
                  {msg.choices && (
                    <div className="mt-2 space-y-1">
                      {msg.choices.map((choice, index) => (
                        <Button
                          key={index}
                          variant="outline"
                          size="sm"
                          className="w-full justify-start text-xs"
                          onClick={() => {
                            setMessage(choice);
                            handleSend();
                          }}
                        >
                          {choice}
                        </Button>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            ))}
            {isTyping && (
              <div className="flex gap-2">
                <div className="h-7 w-7 rounded-full bg-gradient-to-br from-teal-400 to-emerald-500 flex items-center justify-center flex-shrink-0 shadow-sm">
                  <Sprout className="h-3.5 w-3.5 text-white" />
                </div>
                <div className="bg-white rounded-xl p-2.5 shadow-sm border border-neutral-100">
                  <div className="flex gap-1">
                    <div className="w-1.5 h-1.5 bg-teal-500 rounded-full animate-bounce [animation-delay:-0.3s]" />
                    <div className="w-1.5 h-1.5 bg-teal-500 rounded-full animate-bounce [animation-delay:-0.15s]" />
                    <div className="w-1.5 h-1.5 bg-teal-500 rounded-full animate-bounce" />
                  </div>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Input Area */}
          <div className="p-3 border-t border-neutral-100 bg-white/80 backdrop-blur-sm rounded-b-2xl">
            <form 
              className="flex gap-2"
              onSubmit={(e) => {
                e.preventDefault();
                handleSend();
              }}
            >
              <Input
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="Type your message..."
                className="flex-1 text-xs h-8 rounded-xl border-neutral-200"
                disabled={isTyping}
              />
              <Button 
                type="submit" 
                size="icon"
                disabled={!message.trim() || isTyping}
                className="h-8 w-8 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 hover:from-teal-600 hover:to-emerald-600 shadow-sm"
              >
                <Send className="h-3.5 w-3.5" />
              </Button>
            </form>
          </div>
        </Card>
      ) : (
        <div className="relative">
          <TooltipProvider>
            <Tooltip open={showWelcome}>
              <TooltipTrigger asChild>
                <div
                  className="spora-button"
                  onClick={handleOpen}
                  onMouseEnter={() => setIsHovered(true)}
                  onMouseLeave={() => setIsHovered(false)}
                  style={{
                    '--i': 'rgb(13, 148, 136)',
                    '--j': 'rgb(16, 185, 129)',
                  } as React.CSSProperties}
                >
                  <Sprout className={cn(
                    "icon",
                    isHovered && "opacity-0 -translate-x-2"
                  )} />
                  <span className={cn(
                    "title",
                    isHovered && "opacity-100 translate-x-0"
                  )}>
                    Meet Spora
                  </span>
                  <div className="notification-dot" />
                </div>
              </TooltipTrigger>
              <TooltipContent 
                side="left" 
                className="bg-white p-2.5 max-w-[180px] shadow-lg border border-neutral-100 rounded-xl"
              >
                <div className="flex items-center gap-1.5 text-xs font-medium text-neutral-900">
                  <Sprout className="h-3.5 w-3.5 text-teal-500" />
                  Meet Spora
                </div>
                <p className="text-[10px] text-neutral-500 mt-1">
                  Your AI assistant is here to help
                </p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </div>
      )}
    </div>
  );
}

export default SporaChat;