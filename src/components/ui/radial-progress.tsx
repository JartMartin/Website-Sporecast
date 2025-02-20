import { cn } from "@/lib/utils";

interface RadialProgressProps {
  value: number;
  className?: string;
  indicatorColor?: string;
  trackColor?: string;
  children?: React.ReactNode;
}

export function RadialProgress({
  value,
  className,
  indicatorColor = "stroke-teal-600",
  trackColor = "stroke-teal-100",
  children,
}: RadialProgressProps) {
  // Ensure value is between 0 and 100
  const normalizedValue = Math.min(Math.max(value, 0), 100);
  
  // Calculate the stroke dash array and offset for half circle
  const radius = 45; // Slightly smaller than viewBox to account for stroke width
  const circumference = radius * Math.PI; // Only half of the circle
  const offset = circumference - (normalizedValue / 100) * circumference;

  return (
    <div className={cn("relative", className)}>
      <svg
        viewBox="0 0 100 50" // Half the height for semi-circle
        className="rotate-180" // Rotate to show arc at top
      >
        {/* Background Track */}
        <path
          d="M5,0 A45,45 0 1,0 95,0" // Arc path for half circle at top
          fill="none"
          strokeWidth="10"
          className={cn("transition-all duration-500", trackColor)}
          strokeLinecap="round"
        />
        {/* Indicator */}
        <path
          d="M5,0 A45,45 0 1,0 95,0" // Same arc path
          fill="none"
          strokeWidth="10"
          className={cn("transition-all duration-500", indicatorColor)}
          strokeLinecap="round"
          style={{
            strokeDasharray: circumference,
            strokeDashoffset: offset,
          }}
        />
      </svg>
      {/* Content */}
      <div className="absolute inset-0 flex items-center justify-center">
        {children}
      </div>
    </div>
  );
}