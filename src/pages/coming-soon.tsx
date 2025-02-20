import { SporecastLogo } from "@/components/sporecast-logo";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { ChevronLeft, Brain, Code, Users, ArrowDown } from "lucide-react";

export function ComingSoonPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-teal-50 via-emerald-50/50 to-teal-50/30">
      {/* Background Pattern */}
      <div className="absolute inset-0 -z-10">
        <svg
          className="absolute w-full h-full opacity-[0.15]"
          xmlns="http://www.w3.org/2000/svg"
        >
          <defs>
            <pattern
              id="hero-pattern"
              width="32"
              height="32"
              patternUnits="userSpaceOnUse"
            >
              <path d="M0 32V0h32" fill="none" stroke="currentColor" strokeOpacity="0.2" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#hero-pattern)" />
        </svg>
      </div>

      <div className="container max-w-[800px] mx-auto px-4 py-16 relative">
        {/* Back Button */}
        <Link
          to="/"
          className="inline-flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors mb-8"
        >
          <ChevronLeft className="h-4 w-4" />
          Back to Home
        </Link>

        {/* Logo */}
        <div className="text-center mb-12">
          <SporecastLogo className="mx-auto" />
        </div>

        {/* Coming Soon Card */}
        <div className="bg-white/80 backdrop-blur-sm rounded-2xl border border-teal-100 shadow-xl p-8 space-y-12">
          {/* Title */}
          <div className="text-center space-y-4">
            <h1 className="text-3xl font-bold">Coming Soon!</h1>
            <p className="text-gray-600 max-w-2xl mx-auto">
              We're actively developing our web app and working to make our first commodities operational. Our team is focused on training machine learning models and testing the platform to ensure we deliver accurate and reliable forecasts.
            </p>
          </div>

          {/* Current Tasks */}
          <div className="space-y-8">
            <h2 className="text-xl font-semibold text-center">Current Development</h2>
            
            {/* In Progress Tasks */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Training Models */}
              <div className="bg-white rounded-xl p-6 shadow-sm border border-teal-100 transition-all duration-200 hover:shadow-md hover:border-teal-200 group">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-teal-50 to-emerald-50 border border-teal-100 flex items-center justify-center transition-transform duration-200 group-hover:scale-110">
                    <Brain className="h-5 w-5 text-teal-600" />
                  </div>
                  <span className="text-xs px-2 py-1 rounded-full font-medium bg-teal-50 text-teal-700">
                    In Progress
                  </span>
                </div>
                <h3 className="font-medium text-gray-900 mb-2">Training Machine Learning Models</h3>
                <p className="text-sm text-gray-600">Our team is training and fine-tuning advanced neural networks on extensive historical commodity data.</p>
              </div>

              {/* Web App Development */}
              <div className="bg-white rounded-xl p-6 shadow-sm border border-teal-100 transition-all duration-200 hover:shadow-md hover:border-teal-200 group">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-teal-50 to-emerald-50 border border-teal-100 flex items-center justify-center transition-transform duration-200 group-hover:scale-110">
                    <Code className="h-5 w-5 text-teal-600" />
                  </div>
                  <span className="text-xs px-2 py-1 rounded-full font-medium bg-teal-50 text-teal-700">
                    In Progress
                  </span>
                </div>
                <h3 className="font-medium text-gray-900 mb-2">Web Application Development</h3>
                <p className="text-sm text-gray-600">Building a robust and user-friendly platform to deliver real-time insights and forecasts.</p>
              </div>

              {/* Customer Testing */}
              <div className="bg-white rounded-xl p-6 shadow-sm border border-teal-100 transition-all duration-200 hover:shadow-md hover:border-teal-200 group">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-teal-50 to-emerald-50 border border-teal-100 flex items-center justify-center transition-transform duration-200 group-hover:scale-110">
                    <Users className="h-5 w-5 text-teal-600" />
                  </div>
                  <span className="text-xs px-2 py-1 rounded-full font-medium bg-teal-50 text-teal-700">
                    In Progress
                  </span>
                </div>
                <h3 className="font-medium text-gray-900 mb-2">Customer Testing</h3>
                <p className="text-sm text-gray-600">Working closely with founding customers to validate and refine our forecasting models.</p>
              </div>
            </div>

            {/* Arrow Indicator */}
            <div className="flex justify-center">
              <div className="w-10 h-10 rounded-full bg-gradient-to-br from-teal-50 to-emerald-50 border border-teal-100 flex items-center justify-center animate-bounce">
                <ArrowDown className="h-5 w-5 text-teal-600" />
              </div>
            </div>

            {/* Final Step */}
            <div className="max-w-sm mx-auto">
              <div className="bg-white rounded-xl p-6 shadow-sm border border-teal-100 transition-all duration-200 hover:shadow-md hover:border-teal-200">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="font-medium text-gray-900">Launching Sporecast</h3>
                  <span className="text-xs px-2 py-1 rounded-full font-medium bg-amber-50 text-amber-700">
                    Upcoming
                  </span>
                </div>
                <div className="h-1 bg-gray-100 rounded-full overflow-hidden">
                  <div className="h-full w-3/4 bg-gradient-to-r from-teal-500 to-emerald-500 rounded-full" />
                </div>
              </div>
            </div>
          </div>

          {/* Additional Info */}
          <div className="text-center text-sm text-gray-500">
            Want to stay updated on our progress? Follow us on{" "}
            <a 
              href="https://linkedin.com/company/sporecast" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-teal-600 hover:text-teal-700 font-medium"
            >
              LinkedIn
            </a>
            .
          </div>
        </div>
      </div>
    </div>
  );
}

export default ComingSoonPage;