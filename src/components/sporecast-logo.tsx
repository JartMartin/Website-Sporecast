import { Link } from "react-router-dom";
import { cn } from "@/lib/utils";

interface SporecastLogoProps {
  className?: string;
  linkToHome?: boolean;
  variant?: "full" | "icon";
  color?: "white" | "gradient";
}

export function SporecastLogo({ 
  className = "", 
  linkToHome = true,
  variant = "full",
  color = "gradient"
}: SporecastLogoProps) {
  const LogoContent = (
    <div className={cn(
      "flex items-center gap-2 hover:opacity-80 transition-opacity",
      variant === "icon" && "w-6",
      className
    )}>
      <div className={cn(
        "relative",
        color === "white" ? "text-white" : "text-teal-600"
      )}>
        {variant === "icon" ? (
          <img 
            src="/logos/small-logo.svg" 
            alt="Sporecast" 
            className="h-6 w-6"
            style={{ color: 'inherit' }}
          />
        ) : (
          <div className="flex items-center gap-2">
            <img 
              src="/logos/small-logo.svg" 
              alt="" 
              className="h-6 w-6"
              style={{ color: 'inherit' }}
            />
            <span className={cn(
              "font-bold text-xl transition-all duration-200",
              color === "white" 
                ? "text-white" 
                : "bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent",
              variant === "icon" && "w-0 opacity-0 overflow-hidden"
            )}>
              Sporecast
            </span>
          </div>
        )}
      </div>
    </div>
  );

  if (linkToHome) {
    return <Link to="/">{LogoContent}</Link>;
  }

  return LogoContent;
}