import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { ArrowRight, Coffee } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";

interface HeroSectionProps {
  isVisible: boolean;
}

export function HeroSection({ isVisible }: HeroSectionProps) {
  const [isHovered, setIsHovered] = useState(false);
  const [showElements, setShowElements] = useState(false);

  useEffect(() => {
    if (!isVisible) return;

    const timer = setTimeout(() => {
      setShowElements(true);
    }, 100);

    return () => clearTimeout(timer);
  }, [isVisible]);

  return (
    <div className="text-center w-full max-w-[1200px] mx-auto">
      <div className={cn(
        "space-y-8 transition-all duration-500",
        showElements ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
      )}>
        {/* Badge */}
        <Badge 
          variant="outline" 
          className="bg-white/50 backdrop-blur-sm border-teal-200 text-teal-800 px-3 py-1"
        >
          Academically Driven, Economically Guided, Mathematically Powered
        </Badge>

        {/* Title */}
        <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold tracking-tight">
          <span>Stay Ahead of </span>
          <span className="relative whitespace-nowrap">
            <span className={cn(
              "absolute -inset-1 rounded-lg bg-gradient-to-br from-teal-500/20 to-emerald-500/20 blur-lg transition-opacity duration-1000",
              showElements ? "opacity-100" : "opacity-0"
            )} />
            <span className={cn(
              "relative transition-colors duration-1000",
              showElements ? "bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent" : "text-gray-900"
            )}>
              Food Commodity Markets
            </span>
          </span>
          <div className="mt-4">
            with Data-Driven Forecasting
            <span className="relative inline-flex h-2 w-2 ml-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-teal-400 opacity-75" />
              <span className="relative inline-flex rounded-full h-2 w-2 bg-teal-500" />
            </span>
          </div>
        </h1>

        {/* Description */}
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">
          Transform food market uncertainty into reliable, real-time forecasts using best-in-class methods to enhance procurement strategies.
        </p>

        {/* CTA Buttons */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4 max-w-xl mx-auto pt-6">
          <div className="w-full sm:w-auto">
            <Link to="/auth?tab=signup" className="block">
              <Button 
                size="lg" 
                className="w-full sm:w-auto h-[50px] px-8 rounded-[12px] bg-gradient-to-r from-teal-500 to-emerald-500 hover:from-teal-600 hover:to-emerald-600 group relative overflow-hidden"
              >
                <span className="relative z-10 flex items-center justify-center gap-2 text-[15px] font-semibold">
                  Start Free Trial
                  <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                </span>
              </Button>
              <p className="text-[12px] text-center font-medium text-teal-900/70 mt-2">
                14-day free trial • Full premium access
              </p>
            </Link>
          </div>

          <div className="w-full sm:w-auto">
            <Link to="/schedule" className="block">
              <Button 
                variant="outline"
                size="lg"
                className={cn(
                  "w-full sm:w-auto h-[50px] px-8 rounded-[12px]",
                  "border-2 border-teal-600/20 hover:border-teal-600/40",
                  "bg-white/80 backdrop-blur-sm hover:bg-teal-50/50",
                  "transition-all duration-300",
                  "group relative overflow-hidden"
                )}
                onMouseEnter={() => setIsHovered(true)}
                onMouseLeave={() => setIsHovered(false)}
              >
                <span className="relative z-10 flex items-center justify-center gap-2 text-[15px] font-semibold text-teal-700">
                  Schedule an online coffee
                  <Coffee className={cn(
                    "h-4 w-4 transition-all duration-500",
                    isHovered ? "rotate-12 scale-110" : ""
                  )} />
                </span>
              </Button>
              <p className="text-[12px] text-center font-medium text-teal-900/70 mt-2">
                Completely free • No strings attached
              </p>
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}