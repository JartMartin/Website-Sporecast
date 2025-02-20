import { useState, useEffect, useRef } from "react";
import { TrendingUp, Clock, HandCoins, LineChart } from "lucide-react";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { NeuralNetwork } from "./neural-network";

const challenges = [
  {
    icon: TrendingUp,
    title: "Ever-changing market dynamics",
    description: "Complicate turning data into actionable strategies",
  },
  {
    icon: Clock,
    title: "Short-term fluctuations",
    description: "Hinder long-term strategic planning",
  },
  {
    icon: HandCoins,
    title: "Dynamic markets",
    description: "Make confident negotiations a challenge",
  },
  {
    icon: LineChart,
    title: "Speculative traders funds",
    description: "Disrupt price stability",
  },
];

export function ChallengesSection() {
  const [hoveredCard, setHoveredCard] = useState<number | null>(null);
  const [isVisible, setIsVisible] = useState(false);
  const [scrollY, setScrollY] = useState(0);
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const sectionRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
        }
      },
      {
        threshold: 0.1,
        rootMargin: "50px",
      }
    );

    if (sectionRef.current) {
      observer.observe(sectionRef.current);
    }

    const handleScroll = () => {
      setScrollY(window.scrollY);
    };

    window.addEventListener("scroll", handleScroll);
    return () => {
      observer.disconnect();
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!sectionRef.current) return;
    const rect = sectionRef.current.getBoundingClientRect();
    setMousePosition({
      x: ((e.clientX - rect.left) / rect.width) * 100,
      y: ((e.clientY - rect.top) / rect.height) * 100,
    });
  };

  return (
    <div 
      ref={sectionRef} 
      className="relative w-full overflow-hidden"
      onMouseMove={handleMouseMove}
    >
      {/* Enhanced Background with Neural Networks */}
      <div className="absolute inset-0">
        {/* Base Gradient Layer */}
        <div 
          className="absolute inset-0 bg-gradient-to-br from-teal-100/80 via-emerald-50 to-teal-50"
          style={{
            transform: `translateY(${scrollY * 0.1}px)`,
            transition: 'transform 0.2s ease-out',
          }}
        />

        {/* Interactive Gradient following mouse */}
        <div 
          className="absolute inset-0 opacity-75 transition-opacity duration-500"
          style={{
            background: `radial-gradient(circle at ${mousePosition.x}% ${mousePosition.y}%, rgba(20, 184, 166, 0.15) 0%, rgba(16, 185, 129, 0.1) 30%, transparent 70%)`,
            opacity: isVisible ? 1 : 0,
          }}
        />

        {/* Animated Pattern Overlay */}
        <div 
          className="absolute inset-0 opacity-[0.03]"
          style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%2314b8a6' fill-opacity='0.4'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
            transform: `translateY(${-scrollY * 0.05}px)`,
          }}
        />

        {/* Smooth Edge Transitions */}
        <div className="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-white to-transparent" />
        <div className="absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-white to-transparent" />
      </div>

      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 py-24 md:py-32">
        <div className={cn(
          "max-w-3xl mx-auto text-center space-y-6 transition-all duration-1000",
          isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-8"
        )}>
          {/* Section Label */}
          <div className="flex items-center justify-center">
            <span className="inline-flex items-center px-4 py-1.5 rounded-full border border-teal-200 bg-teal-50/50 backdrop-blur-sm">
              <span className="text-sm font-medium text-teal-900">
                Agri-market challenges
              </span>
            </span>
          </div>

          {/* Title with Neural Networks */}
          <div className="relative">
            {/* Left Neural Network */}
            <div className="absolute -left-32 -top-12">
              <NeuralNetwork width={200} height={200} nodeCount={8} />
            </div>

            {/* Right Neural Network */}
            <div className="absolute -right-32 -top-12">
              <NeuralNetwork width={200} height={200} nodeCount={8} />
            </div>

            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 relative z-10">
              Your solution for minimalising guesswork with{" "}
              <span className="relative inline-block">
                <span className="relative z-20">
                  proactive, data-driven
                </span>
                <span className="absolute bottom-1 left-0 w-full h-[6px] bg-teal-600 rounded-full -z-10" />
              </span>{" "}
              insights in food commodity markets.
            </h2>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-8 max-w-5xl mx-auto mt-16">
          {challenges.map((challenge, index) => {
            const Icon = challenge.icon;
            const isHovered = hoveredCard === index;
            const delay = index * 200;

            return (
              <Card 
                key={index}
                className={cn(
                  "group relative p-6 transition-all duration-500",
                  "bg-white/95 hover:bg-white",
                  "hover:shadow-lg hover:shadow-teal-900/5",
                  "border border-teal-100",
                  "transform hover:-translate-y-1",
                  isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-8"
                )}
                style={{
                  transitionDelay: `${delay}ms`,
                }}
                onMouseEnter={() => setHoveredCard(index)}
                onMouseLeave={() => setHoveredCard(null)}
              >
                <div className="flex items-start gap-4">
                  <div className={cn(
                    "rounded-lg p-3 transition-all duration-300",
                    "bg-teal-50 text-teal-600",
                    isHovered && "bg-teal-100 scale-110 rotate-3"
                  )}>
                    <Icon className="h-6 w-6" />
                  </div>
                  <div className="flex-1 space-y-2">
                    <h3 className="font-semibold text-lg group-hover:text-teal-900 transition-colors duration-300">
                      {challenge.title}
                    </h3>
                    <p className="text-muted-foreground group-hover:text-gray-600 transition-colors duration-300">
                      {challenge.description}
                    </p>
                  </div>
                </div>

                {/* Hover Effect Overlay */}
                <div className={cn(
                  "absolute inset-0 bg-gradient-to-br from-teal-50/50 to-emerald-50/50 rounded-lg opacity-0 transition-opacity duration-300",
                  isHovered && "opacity-100"
                )} />
              </Card>
            );
          })}
        </div>
      </div>
    </div>
  );
}