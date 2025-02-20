import { cn } from "@/lib/utils";
import { Link, useLocation } from "react-router-dom";
import { SporecastLogo } from "@/components/sporecast-logo";
import { Button } from "@/components/ui/button";
import { useEffect, useState } from "react";

export function MainNav() {
  const location = useLocation();
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      const scrollPosition = window.scrollY;
      setIsScrolled(scrollPosition > 10);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div className={cn(
      "w-full px-4 sm:px-6 lg:px-8 z-50 transition-all duration-300",
      isScrolled ? "fixed top-0 py-4" : "absolute top-6"
    )}>
      <div className="max-w-screen-xl mx-auto">
        <nav className={cn(
          "bg-white/95 rounded-xl shadow-sm border border-white/20 backdrop-blur-sm",
          "transition-all duration-300",
          isScrolled && "shadow-md"
        )}>
          <div className="flex h-16 items-center px-6">
            {/* Logo - Left */}
            <div className="flex-none">
              <SporecastLogo />
            </div>

            {/* Navigation - Center */}
            <div className="flex-1 flex justify-center">
              <div className="flex items-center gap-1">
                <Link
                  to="/features"
                  className={cn(
                    "px-4 py-2 text-sm font-medium rounded-md transition-colors",
                    "text-gray-600 hover:text-gray-900 hover:bg-gray-50",
                    location.pathname === "/features" && "bg-teal-50 text-teal-900"
                  )}
                >
                  Features
                </Link>

                <Link
                  to="/commodities"
                  className={cn(
                    "px-4 py-2 text-sm font-medium rounded-md transition-colors",
                    "text-gray-600 hover:text-gray-900 hover:bg-gray-50",
                    location.pathname === "/commodities" && "bg-teal-50 text-teal-900"
                  )}
                >
                  Commodity Catalog
                </Link>

                <Link
                  to="/pricing"
                  className={cn(
                    "px-4 py-2 text-sm font-medium rounded-md transition-colors",
                    "text-gray-600 hover:text-gray-900 hover:bg-gray-50",
                    location.pathname === "/pricing" && "bg-teal-50 text-teal-900"
                  )}
                >
                  Pricing
                </Link>

                <Link
                  to="/story"
                  className={cn(
                    "px-4 py-2 text-sm font-medium rounded-md transition-colors",
                    "text-gray-600 hover:text-gray-900 hover:bg-gray-50",
                    location.pathname === "/story" && "bg-teal-50 text-teal-900"
                  )}
                >
                  Our Story
                </Link>
              </div>
            </div>

            {/* Auth Buttons - Right */}
            <div className="flex-none flex items-center gap-2">
              <Link to="/auth">
                <Button 
                  variant="ghost" 
                  size="sm"
                  className="text-gray-600 hover:text-gray-900 hover:bg-teal-50"
                >
                  Log in
                </Button>
              </Link>
              <Link to="/auth?tab=signup">
                <Button 
                  size="sm"
                  className="bg-teal-500 hover:bg-teal-600 text-white transition-colors"
                >
                  Sign up
                </Button>
              </Link>
            </div>
          </div>
        </nav>
      </div>
    </div>
  );
}