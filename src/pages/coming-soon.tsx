import { SporecastLogo } from "@/components/sporecast-logo";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { ChevronLeft, Brain, Code, Users, ArrowDown, Sprout } from "lucide-react";
import { WaitlistForm } from "@/components/waitlist/waitlist-form";
import { cn } from "@/lib/utils";
import { useState, useEffect } from "react";

export function ComingSoonPage() {
  const [isVisible, setIsVisible] = useState(false);
  const [mousePosition, setMousePosition] = useState({ x: 50, y: 50 });

  useEffect(() => {
    setIsVisible(true);
  }, []);

  const handleMouseMove = (e: React.MouseEvent) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = ((e.clientX - rect.left) / rect.width) * 100;
    const y = ((e.clientY - rect.top) / rect.height) * 100;
    setMousePosition({ x, y });
  };

  return (
    <div 
      className="min-h-screen bg-gradient-to-br from-teal-50 via-emerald-50/50 to-teal-50/30"
      onMouseMove={handleMouseMove}
    >
      {/* Interactive Background */}
      <div className="absolute inset-0 -z-10">
        {/* Base Grid Pattern */}
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

        {/* Interactive Gradient */}
        <div 
          className="absolute inset-0 opacity-75 transition-opacity duration-500"
          style={{
            background: `radial-gradient(circle at ${mousePosition.x}% ${mousePosition.y}%, rgba(20, 184, 166, 0.15) 0%, rgba(16, 185, 129, 0.1) 30%, transparent 70%)`,
          }}
        />

        {/* Edge Gradients */}
        <div className="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-white to-transparent" />
        <div className="absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-white to-transparent" />
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
          <div className="relative w-16 h-16 mx-auto">
            <div className="absolute inset-0 bg-gradient-to-br from-teal-400/20 to-emerald-500/20 rounded-xl blur-lg animate-pulse" />
            <div className="relative bg-gradient-to-br from-teal-50 to-emerald-50/50 rounded-xl border border-teal-100 p-4 shadow-sm">
              <Sprout className="h-8 w-8 text-teal-600" />
            </div>
          </div>
        </div>

        {/* Coming Soon Card */}
        <div className={cn(
          "bg-white/80 backdrop-blur-sm rounded-2xl border border-teal-100 shadow-xl p-8 space-y-12",
          "transition-all duration-1000",
          isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
        )}>
          {/* Title */}
          <div className="text-center space-y-4">
            <h1 className="text-3xl font-bold">
              Building the Future of{" "}
              <span className="bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
                Commodity Forecasting
              </span>
            </h1>
            <p className="text-gray-600 max-w-2xl mx-auto">
              We're actively developing our platform to revolutionize how businesses approach commodity procurement. Our team is focused on training advanced machine learning models and building intuitive tools to deliver accurate, reliable forecasts.
            </p>
          </div>

          {/* Progress Section */}
          <div className="space-y-8">
            <h2 className="text-xl font-semibold text-center">Development Progress</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Training Models */}
              <div className="bg-white rounded-xl p-6 shadow-sm border border-teal-100 transition-all duration-200 hover:shadow-md hover:border-teal-200 group h-[200px] flex flex-col">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-teal-50 to-emerald-50 border border-teal-100 flex items-center justify-center transition-transform duration-200 group-hover:scale-110">
                    <Brain className="h-5 w-5 text-teal-600" />
                  </div>
                  <div className="flex items-center gap-1.5">
                    <span className="relative flex h-2 w-2">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-teal-400 opacity-75" />
                      <span className="relative inline-flex rounded-full h-2 w-2 bg-teal-500" />
                    </span>
                    <span className="text-xs font-medium text-teal-700">Active</span>
                  </div>
                </div>
                <div className="flex-1 flex flex-col justify-center">
                  <h3 className="font-medium text-gray-900 mb-2">Training Models</h3>
                  <p className="text-sm text-gray-600">Fine-tuning neural networks on extensive historical data.</p>
                </div>
              </div>

              {/* Platform Development */}
              <div className="bg-white rounded-xl p-6 shadow-sm border border-teal-100 transition-all duration-200 hover:shadow-md hover:border-teal-200 group h-[200px] flex flex-col">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-teal-50 to-emerald-50 border border-teal-100 flex items-center justify-center transition-transform duration-200 group-hover:scale-110">
                    <Code className="h-5 w-5 text-teal-600" />
                  </div>
                  <div className="flex items-center gap-1.5">
                    <span className="relative flex h-2 w-2">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-teal-400 opacity-75" />
                      <span className="relative inline-flex rounded-full h-2 w-2 bg-teal-500" />
                    </span>
                    <span className="text-xs font-medium text-teal-700">Active</span>
                  </div>
                </div>
                <div className="flex-1 flex flex-col justify-center">
                  <h3 className="font-medium text-gray-900 mb-2">Platform Development</h3>
                  <p className="text-sm text-gray-600">Building an intuitive interface for market insights.</p>
                </div>
              </div>

              {/* Testing & Validation */}
              <div className="bg-white rounded-xl p-6 shadow-sm border border-teal-100 transition-all duration-200 hover:shadow-md hover:border-teal-200 group h-[200px] flex flex-col">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-teal-50 to-emerald-50 border border-teal-100 flex items-center justify-center transition-transform duration-200 group-hover:scale-110">
                    <Users className="h-5 w-5 text-teal-600" />
                  </div>
                  <div className="flex items-center gap-1.5">
                    <span className="relative flex h-2 w-2">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-teal-400 opacity-75" />
                      <span className="relative inline-flex rounded-full h-2 w-2 bg-teal-500" />
                    </span>
                    <span className="text-xs font-medium text-teal-700">Active</span>
                  </div>
                </div>
                <div className="flex-1 flex flex-col justify-center">
                  <h3 className="font-medium text-gray-900 mb-2">Testing & Validation</h3>
                  <p className="text-sm text-gray-600">Working with partners to validate our forecasts.</p>
                </div>
              </div>
            </div>

            {/* Launch Timeline */}
            <div className="relative pt-8">
              {/* Bouncing Arrow */}
              <div className="flex items-center justify-center mb-4">
                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-teal-50 to-emerald-50 border border-teal-100 flex items-center justify-center animate-bounce shadow-sm">
                  <ArrowDown className="h-5 w-5 text-teal-600" />
                </div>
              </div>

              {/* Launch Card */}
              <div className="max-w-sm mx-auto relative">
                <div className="absolute inset-x-0 -top-4 h-4 bg-gradient-to-b from-white to-transparent" />
                <div className="bg-white rounded-xl p-6 shadow-sm border border-teal-100 transition-all duration-200 hover:shadow-md hover:border-teal-200">
                  <div className="flex items-center justify-between mb-3">
                    <h3 className="font-medium text-gray-900">Platform Launch</h3>
                    <span className="text-xs px-2 py-1 rounded-full font-medium bg-amber-50 text-amber-700">
                      Coming Soon
                    </span>
                  </div>
                  <div className="h-1.5 bg-gray-100 rounded-full overflow-hidden">
                    <div className="h-full w-[75%] bg-gradient-to-r from-teal-500 to-emerald-500 rounded-full" />
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Waitlist Form */}
          <div className="pt-8 border-t border-teal-100/50">
            <WaitlistForm />
          </div>

          {/* Social Links */}
          <div className="text-center space-y-4">
            <p className="text-sm text-gray-600">
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
            </p>
            <p className="text-xs text-gray-500">
              © {new Date().getFullYear()} Sporecast. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default ComingSoonPage;