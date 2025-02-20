import { cn } from "@/lib/utils";
import { PriceRange } from "@/lib/types";

interface PriceRangeSliderProps {
  range: PriceRange;
  className?: string;
  dotClassName?: string;
}

export function PriceRangeSlider({ range, className, dotClassName }: PriceRangeSliderProps) {
  const total = range.high - range.low;
  const position = ((range.current - range.low) / total) * 100;

  return (
    <div className="space-y-4">
      <div className="flex justify-between text-sm text-neutral-600">
        <span>€{range.low.toFixed(2)}</span>
        <span>€{range.high.toFixed(2)}</span>
      </div>
      <div className="relative h-2 bg-neutral-100 rounded-full">
        <div 
          className={cn(
            "absolute inset-y-0 left-0 rounded-full",
            className
          )}
          style={{ width: `${position}%` }}
        />
        <div 
          className={cn(
            "absolute h-4 w-4 top-1/2 -translate-y-1/2 rounded-full border-2 border-white shadow-sm",
            dotClassName
          )}
          style={{ left: `${position}%` }}
        />
      </div>
      <div className="text-center text-sm font-medium text-neutral-900">
        Current: €{range.current.toFixed(2)}
      </div>
    </div>
  );
}