import { Button } from "@/components/ui/button";
import { ArrowDown } from "lucide-react";
import { cn } from "@/lib/utils";
import { NeuralNetwork } from "./neural-network";

interface HowItWorksHeaderProps {
  isExpanded: boolean;
  onExpandChange: (expanded: boolean) => void;
}

export function HowItWorksHeader({ isExpanded, onExpandChange }: HowItWorksHeaderProps) {
  return (
    <div className="max-w-3xl mx-auto text-center space-y-6">
      <div className="inline-flex items-center rounded-full border border-teal-200 bg-teal-50/50 px-4 py-1.5">
        <span className="text-sm font-medium text-teal-900">
          How Sporecast Works
        </span>
      </div>

      <div className="relative">
        {/* Left Neural Network */}
        <div className="absolute -left-32 -top-12">
          <NeuralNetwork width={200} height={200} nodeCount={8} />
        </div>

        {/* Right Neural Network */}
        <div className="absolute -right-32 -top-12">
          <NeuralNetwork width={200} height={200} nodeCount={8} />
        </div>

        <h2 className="text-4xl font-bold tracking-tight relative z-10">
          Build Your Own{" "}
          <span className="relative whitespace-nowrap">
            <span className="relative bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
              Commodity Portfolio
            </span>
          </span>
        </h2>
      </div>
      
      <p className="text-lg text-gray-600 relative z-10">
        Get tailored forecast insights for each commodity in your portfolio
      </p>

      <Button
        variant="outline"
        size="lg"
        onClick={() => onExpandChange(!isExpanded)}
        className="group border-2 border-teal-600/20 hover:border-teal-600/40 bg-white hover:bg-teal-50/50 relative z-10"
      >
        <span className="bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent group-hover:text-teal-700 flex items-center gap-2">
          {isExpanded ? "Show Less" : "Learn More"}
          <ArrowDown className={cn(
            "h-4 w-4 transition-all duration-300",
            isExpanded ? "rotate-180" : ""
          )} />
        </span>
      </Button>
    </div>
  );
}