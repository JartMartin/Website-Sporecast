import { MainNav } from "@/components/navigation/main-nav";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { ArrowRight, Brain, Clock, Shield } from "lucide-react";
import { cn } from "@/lib/utils";
import { SporaChat } from "@/components/spora-chat";
import { Footer } from "@/components/landing/footer";

const features = [
  {
    id: "ai-analysis",
    icon: Brain,
    title: "AI-Powered Analysis",
    description: "Advanced machine learning models analyze market trends and patterns.",
    benefits: [
      "Real-time market analysis",
      "Pattern recognition",
      "Anomaly detection",
      "Trend forecasting"
    ]
  },
  {
    id: "real-time",
    icon: Clock,
    title: "Real-Time Insights",
    description: "Instant market updates and alerts on price changes and market conditions.",
    benefits: [
      "Live price tracking",
      "Instant notifications",
      "Market alerts",
      "Custom thresholds"
    ]
  },
  {
    id: "risk",
    icon: Shield,
    title: "Risk Management",
    description: "Comprehensive tools for risk assessment and management.",
    benefits: [
      "Risk assessment",
      "Portfolio analysis",
      "Volatility tracking",
      "Scenario planning"
    ]
  }
];

export function FeaturesPage() {
  return (
    <div className="min-h-screen flex flex-col bg-white">
      <MainNav />

      <main className="flex-1">
        {/* Hero Section */}
        <div className="relative pt-32 pb-12 md:pt-40 md:pb-24 bg-gray-50">
          <div className="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="max-w-3xl mx-auto text-center space-y-8">
              <h1 className="text-4xl md:text-5xl font-bold tracking-tight">
                Powerful Features for{" "}
                <span className="bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
                  Smarter Trading
                </span>
              </h1>
              <p className="text-xl text-gray-600">
                Discover how our platform can transform your approach to commodity trading with cutting-edge technology.
              </p>
              <Link to="/auth?tab=signup">
                <Button 
                  size="lg"
                  className="group bg-gradient-to-r from-teal-500 to-emerald-500 hover:from-teal-600 hover:to-emerald-600"
                >
                  <span className="flex items-center gap-2">
                    Start Free Trial
                    <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                  </span>
                </Button>
              </Link>
            </div>
          </div>
        </div>

        {/* Features Section */}
        <div className="py-12 md:py-24">
          <div className="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="space-y-24">
              {features.map((feature, index) => {
                const Icon = feature.icon;
                return (
                  <div
                    key={feature.id}
                    id={feature.id}
                    className={cn(
                      "grid grid-cols-1 lg:grid-cols-2 gap-12 items-center",
                      index % 2 === 1 && "lg:flex-row-reverse"
                    )}
                  >
                    <div className="space-y-6">
                      <div className="inline-block rounded-lg bg-teal-100 p-3">
                        <Icon className="h-6 w-6 text-teal-600" />
                      </div>
                      <h2 className="text-3xl font-bold">{feature.title}</h2>
                      <p className="text-xl text-gray-600">{feature.description}</p>
                      <ul className="space-y-3">
                        {feature.benefits.map((benefit) => (
                          <li key={benefit} className="flex items-center gap-3">
                            <div className="h-1.5 w-1.5 rounded-full bg-teal-500" />
                            <span className="text-gray-600">{benefit}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                    <div className="aspect-square bg-gradient-to-br from-gray-50 to-white p-8 rounded-2xl border shadow-sm flex items-center justify-center">
                      <Icon className="h-32 w-32 text-teal-500 opacity-80" />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </main>

      <Footer />
      <SporaChat />
    </div>
  );
}

export default FeaturesPage;