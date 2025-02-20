import { useEffect } from "react";
import { useLocation } from "react-router-dom";
import { AuthTabs } from "@/components/auth/auth-tabs";
import { SporecastLogo } from "@/components/sporecast-logo";
import { QuoteCarousel } from "@/components/auth/quote-carousel";

interface AuthPageProps {
  initialTab?: "login" | "signup";
}

export function AuthPage({ initialTab }: AuthPageProps) {
  const location = useLocation();

  return (
    <div className="flex min-h-screen">
      {/* Left Panel */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-teal-400 to-emerald-500 p-12 flex-col justify-between">
        <SporecastLogo className="h-8 w-auto" linkToHome={true} color="white" />
        <QuoteCarousel />
      </div>

      {/* Right Panel */}
      <div className="flex-1 flex items-center justify-center p-4 sm:p-8">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <div className="lg:hidden mb-8">
              <SporecastLogo linkToHome={true} color="gradient" />
            </div>
            <h2 className="text-2xl font-bold tracking-tight mb-3">
              Welcome to Sporecast
            </h2>
            <p className="text-muted-foreground">
              Experience the future of commodity forecasting with our AI-powered platform
            </p>
          </div>

          <AuthTabs initialTab={initialTab} />
        </div>
      </div>
    </div>
  );
}

export default AuthPage;