import { useState, useEffect, useRef } from "react";
import { Briefcase, LayoutDashboard, BarChart2, Bell } from "lucide-react";
import { HowItWorksHeader } from "./how-it-works-header";
import { HowItWorksStep } from "./how-it-works-step";

const steps = [
  {
    number: "01",
    title: "Build Your Custom Commodity Portfolio",
    description: "Easily select the commodities that matter most to your business and build your personalized portfolio in just a few steps. Focus on what matters to you, and track your key assets with ease.",
  },
  {
    number: "02",
    title: "View Your Portfolio's Performance in Real-Time",
    description: "See the complete status of your procurement assets with real-time updates on price shifts and market conditions across all commodities, providing the clarity to guide your decisions.",
  },
  {
    number: "03",
    title: "Commodity-Specific Forecasts & Insights",
    description: "Access refined short- and long-term forecasts, market conditions, and model performance to guide your commodity strategy with confidence.",
  },
  {
    number: "04",
    title: "Set Alerts and Stay Informed",
    description: "Set personalized alerts for price changes or market shifts, and receive real-time notifications to stay ahead of key movements—ensuring you're always ready to act when it matters most.",
  },
];

interface HowItWorksProps {
  scrollY: number;
}

export function HowItWorks({ scrollY }: HowItWorksProps) {
  const [isExpanded, setIsExpanded] = useState(false);
  const [hoveredStep, setHoveredStep] = useState<number | null>(null);
  const [visibleSteps, setVisibleSteps] = useState<number[]>([]);
  const stepsRef = useRef<(HTMLDivElement | null)[]>([]);

  useEffect(() => {
    const handleScroll = () => {
      if (!isExpanded) return;

      stepsRef.current.forEach((step, index) => {
        if (!step) return;
        
        const rect = step.getBoundingClientRect();
        const isInView = rect.top <= window.innerHeight * 0.8;
        
        if (isInView && !visibleSteps.includes(index)) {
          setVisibleSteps(prev => [...prev, index]);
        }
      });
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    handleScroll(); // Initial check
    return () => window.removeEventListener("scroll", handleScroll);
  }, [visibleSteps, isExpanded]);

  return (
    <section className="relative w-full overflow-hidden py-24 sm:py-32">
      {/* Enhanced Green Background */}
      <div className="absolute inset-0 -z-10">
        {/* Main Gradient Background */}
        <div className="absolute inset-0 bg-gradient-to-br from-teal-100/80 via-emerald-50 to-teal-50" />
        
        {/* Additional Green Overlay */}
        <div 
          className="absolute inset-0 bg-gradient-to-r from-teal-500/5 to-emerald-500/10"
          style={{
            mixBlendMode: 'multiply',
          }}
        />
        
        {/* Animated Gradient */}
        <div 
          className="absolute inset-0 opacity-30"
          style={{
            background: `radial-gradient(circle at ${50 + Math.sin(scrollY * 0.02) * 10}% ${50 + Math.cos(scrollY * 0.02) * 10}%, rgba(20, 184, 166, 0.15) 0%, rgba(16, 185, 129, 0.15) 50%, transparent 100%)`,
          }}
        />

        {/* Grid Pattern */}
        <svg
          className="absolute w-full h-full opacity-[0.15]"
          xmlns="http://www.w3.org/2000/svg"
        >
          <defs>
            <pattern id="grid" width="32" height="32" patternUnits="userSpaceOnUse">
              <path d="M0 32V0h32" fill="none" stroke="currentColor" strokeOpacity="0.2" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#grid)" />
        </svg>

        {/* Soft Edge Gradients */}
        <div className="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-white to-transparent" />
        <div className="absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-white to-transparent" />
      </div>

      <div className="mx-auto max-w-screen-xl px-4 sm:px-6 lg:px-8">
        <HowItWorksHeader 
          isExpanded={isExpanded}
          onExpandChange={setIsExpanded}
        />

        {/* Enhanced Expanded Content */}
        {isExpanded && (
          <div className="mt-12 space-y-12">
            {steps.map((step, index) => (
              <div key={step.number} ref={el => stepsRef.current[index] = el}>
                <HowItWorksStep
                  {...step}
                  isVisible={visibleSteps.includes(index)}
                  isHovered={hoveredStep === index}
                  isEven={index % 2 === 0}
                  onHover={(hovered) => setHoveredStep(hovered ? index : null)}
                />
              </div>
            ))}
          </div>
        )}
      </div>
    </section>
  );
}

export default HowItWorks;