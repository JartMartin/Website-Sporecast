import { Link } from "react-router-dom";
import { ArrowRight, Briefcase, LayoutDashboard, BarChart2, Bell } from "lucide-react";
import { cn } from "@/lib/utils";

interface HowItWorksStepProps {
  number: string;
  title: string;
  description: string;
  isVisible: boolean;
  isHovered: boolean;
  isEven: boolean;
  onHover: (hovered: boolean) => void;
}

// Get icon based on step number
function getStepIcon(number: string) {
  switch (number) {
    case "01": return Briefcase;    // Portfolio management
    case "02": return LayoutDashboard; // Overview/Dashboard
    case "03": return BarChart2;    // Metrics/Performance
    case "04": return Bell;         // Alerts/Notifications
    default: return Briefcase;
  }
}

export function HowItWorksStep({
  number,
  title,
  description,
  isVisible,
  isHovered,
  isEven,
  onHover
}: HowItWorksStepProps) {
  const Icon = getStepIcon(number);
  
  return (
    <div
      className={cn(
        "grid grid-cols-1 lg:grid-cols-2 gap-6 items-center",
        "transition-all duration-1000 group",
        isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-8"
      )}
      onMouseEnter={() => onHover(true)}
      onMouseLeave={() => onHover(false)}
    >
      {/* Content Section */}
      <div className={cn(
        "space-y-4",
        isEven ? "lg:order-2" : "lg:order-1"
      )}>
        <div className="flex items-center gap-4">
          <div className="text-3xl font-bold text-teal-600/20">
            {number}
          </div>
          <div className={cn(
            "h-12 w-12 rounded-xl flex items-center justify-center",
            "bg-gradient-to-br from-teal-50 to-emerald-50",
            "border border-teal-100",
            "transition-all duration-300",
            isHovered && "scale-110 rotate-3 shadow-md bg-gradient-to-br from-teal-100 to-emerald-100"
          )}>
            <Icon className="h-6 w-6 text-teal-600" />
          </div>
        </div>

        <div className={cn(
          "relative p-6 rounded-xl transition-all duration-300",
          "bg-white/80 backdrop-blur-sm border border-teal-100/50",
          "hover:border-teal-200/50 hover:shadow-lg hover:shadow-teal-900/5",
          isHovered && "transform scale-[1.02]"
        )}>
          <div className="relative z-10">
            <h3 className="text-lg font-bold mb-1.5">{title}</h3>
            <p className="text-gray-600 leading-relaxed text-sm">{description}</p>
            <Link 
              to="/features" 
              className={cn(
                "inline-flex items-center gap-2 mt-2 text-sm text-teal-600",
                "opacity-0 group-hover:opacity-100 transition-opacity duration-300"
              )}
            >
              Learn more about this feature
              <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-1" />
            </Link>
          </div>

          {/* Background Pattern */}
          <div className={cn(
            "absolute inset-0 rounded-xl transition-opacity duration-300",
            "bg-[radial-gradient(#10b98120_1px,transparent_1px)] [background-size:16px_16px]",
            isHovered ? "opacity-100" : "opacity-0"
          )} />

          {/* Hover Effect */}
          <div className={cn(
            "absolute inset-0 rounded-xl transition-opacity duration-300",
            "bg-gradient-to-br from-teal-50/50 to-emerald-50/50",
            isHovered ? "opacity-100" : "opacity-0"
          )} />
        </div>
      </div>

      {/* Empty Space for Layout Balance */}
      <div className={cn(
        "hidden lg:block",
        isEven ? "lg:order-1" : "lg:order-2"
      )} />
    </div>
  );
}