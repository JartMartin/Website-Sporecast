import { useState, useEffect, useRef } from "react";
import { Link } from "react-router-dom";
import { ArrowRight, Coffee } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface Star {
  x: number;
  y: number;
  size: number;
  opacity: number;
  speed: number;
  angle: number;
  color: string;
}

interface Sparkle {
  x: number;
  y: number;
  size: number;
  duration: number;
}

export function FinalCta() {
  const [isHovered, setIsHovered] = useState(false);
  const [mousePosition, setMousePosition] = useState({ x: 50, y: 50 });
  const [stars, setStars] = useState<Star[]>([]);
  const [sparkles, setSparkles] = useState<Sparkle[]>([]);
  const animationFrameRef = useRef<number>();
  const sectionRef = useRef<HTMLElement>(null);

  // Initialize stars with different colors
  useEffect(() => {
    const colors = [
      'rgb(13, 148, 136)', // teal-600
      'rgb(16, 185, 129)', // emerald-500
      'rgb(20, 184, 166)', // teal-500
      'rgb(5, 150, 105)',  // emerald-600
    ];

    const initialStars = Array.from({ length: 150 }, () => ({
      x: Math.random() * 100,
      y: Math.random() * 100,
      size: Math.random() * 3 + 1,
      opacity: Math.random() * 0.5 + 0.2,
      speed: Math.random() * 0.05 + 0.02,
      angle: Math.random() * Math.PI * 2,
      color: colors[Math.floor(Math.random() * colors.length)]
    }));
    setStars(initialStars);
  }, []);

  // Animate stars and handle sparkles
  useEffect(() => {
    let lastSparkleTime = 0;
    const sparkleInterval = 500; // Minimum time between sparkles

    const animate = (timestamp: number) => {
      // Animate stars
      setStars(prevStars => 
        prevStars.map(star => {
          const radius = 0.5;
          const newX = star.x + Math.cos(star.angle) * radius * star.speed;
          const newY = star.y + Math.sin(star.angle) * radius * star.speed;
          const newAngle = star.angle + star.speed;

          return {
            ...star,
            x: ((newX + 100) % 100),
            y: ((newY + 100) % 100),
            angle: newAngle,
            opacity: star.opacity + Math.sin(newAngle) * 0.1
          };
        })
      );

      // Add new sparkles occasionally
      if (timestamp - lastSparkleTime > sparkleInterval) {
        setSparkles(prev => [
          ...prev,
          {
            x: Math.random() * 100,
            y: Math.random() * 100,
            size: Math.random() * 10 + 5,
            duration: Math.random() * 1000 + 1000
          }
        ].slice(-20)); // Keep only the last 20 sparkles
        lastSparkleTime = timestamp;
      }

      // Remove old sparkles
      setSparkles(prev => prev.filter(sparkle => sparkle.duration > 0));

      animationFrameRef.current = requestAnimationFrame(animate);
    };

    animationFrameRef.current = requestAnimationFrame(animate);

    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, []);

  const handleMouseMove = (e: React.MouseEvent<HTMLElement>) => {
    if (!sectionRef.current) return;
    const rect = sectionRef.current.getBoundingClientRect();
    const x = ((e.clientX - rect.left) / rect.width) * 100;
    const y = ((e.clientY - rect.top) / rect.height) * 100;
    setMousePosition({ x, y });

    // Add sparkle at mouse position
    setSparkles(prev => [
      ...prev,
      {
        x: x,
        y: y,
        size: Math.random() * 8 + 4,
        duration: 1000
      }
    ].slice(-30)); // Keep only the last 30 sparkles
  };

  return (
    <section 
      ref={sectionRef}
      className="relative w-full overflow-hidden py-24 sm:py-32"
      onMouseMove={handleMouseMove}
    >
      {/* Enhanced Cosmic Background */}
      <div className="absolute inset-0">
        {/* Deep Space Gradient */}
        <div className="absolute inset-0 bg-gradient-to-br from-teal-50/90 via-emerald-50/70 to-teal-50/80" />
        
        {/* Stars Layer */}
        <div className="absolute inset-0">
          {stars.map((star, i) => (
            <div
              key={i}
              className="absolute rounded-full transition-all duration-1000"
              style={{
                left: `${star.x}%`,
                top: `${star.y}%`,
                width: `${star.size}px`,
                height: `${star.size}px`,
                opacity: star.opacity,
                background: `radial-gradient(circle at center, ${star.color} 0%, transparent 70%)`,
                boxShadow: `0 0 ${star.size * 2}px ${star.color.replace('rgb', 'rgba').replace(')', ', 0.8)')}`,
                transform: `scale(${1 + Math.sin(star.angle) * 0.2})`,
              }}
            />
          ))}
        </div>

        {/* Sparkles Layer */}
        <div className="absolute inset-0">
          {sparkles.map((sparkle, i) => (
            <div
              key={i}
              className="absolute"
              style={{
                left: `${sparkle.x}%`,
                top: `${sparkle.y}%`,
                width: `${sparkle.size}px`,
                height: `${sparkle.size}px`,
                animation: `sparkle-fade ${sparkle.duration}ms linear forwards`,
              }}
            >
              <svg
                viewBox="0 0 24 24"
                fill="none"
                className="w-full h-full text-teal-500"
              >
                <path
                  d="M12 0L14 10L24 12L14 14L12 24L10 14L0 12L10 10L12 0Z"
                  fill="currentColor"
                />
              </svg>
            </div>
          ))}
        </div>

        {/* Interactive Nebula Effect */}
        <div 
          className="absolute inset-0 transition-opacity duration-500"
          style={{
            background: `
              radial-gradient(
                circle at ${mousePosition.x}% ${mousePosition.y}%, 
                rgba(13, 148, 136, 0.2) 0%, 
                rgba(16, 185, 129, 0.15) 20%, 
                rgba(20, 184, 166, 0.1) 40%,
                transparent 70%
              )
            `,
          }}
        />

        {/* Cosmic Grid with Parallax */}
        <div 
          className="absolute inset-0 opacity-[0.05]"
          style={{
            backgroundImage: `
              linear-gradient(rgba(13, 148, 136, 0.5) 1px, transparent 1px),
              linear-gradient(to right, rgba(13, 148, 136, 0.5) 1px, transparent 1px)
            `,
            backgroundSize: '50px 50px',
            transform: `
              translateX(${(mousePosition.x - 50) * 0.02}px)
              translateY(${(mousePosition.y - 50) * 0.02}px)
              rotate(${(mousePosition.x - 50) * 0.01}deg)
            `,
            transition: 'transform 0.5s ease-out'
          }}
        />

        {/* Edge Gradients */}
        <div className="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-white to-transparent" />
        <div className="absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-white to-transparent" />
      </div>

      {/* Content */}
      <div className="relative max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl mx-auto text-center space-y-8">
          <h2 className="text-4xl font-bold tracking-tight sm:text-5xl">
            Shape your{" "}
            <span className="relative whitespace-nowrap">
              <span className="relative bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
                Future-Focused
              </span>
            </span>
            {" "}Strategy
          </h2>

          <div className="relative">
            <div className="absolute inset-0 bg-white/90 backdrop-blur-sm rounded-2xl" />
            <p className="relative text-xl text-gray-600 px-4 py-6">
              Make confident decisions with real-time data and insights powered by cutting-edge neural networks and deep learning. Our platform eliminates guesswork, helping you navigate market fluctuations with clarity and precision, and make smarter, data-driven choices for long-term success.
            </p>
          </div>

          <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4 max-w-xl mx-auto pt-4">
            <Link to="/auth?tab=signup" className="flex-1">
              <Button 
                size="lg" 
                className="w-full relative group overflow-hidden h-12"
              >
                <span className="relative z-10 flex items-center justify-center gap-2 font-medium">
                  Start my free Demo
                  <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                </span>
                <div className="absolute inset-0 bg-gradient-to-r from-teal-500 to-emerald-500 transition-transform group-hover:scale-[1.02]" />
              </Button>
            </Link>

            <div className="hidden sm:block h-12">
              <div className="h-full w-px bg-teal-100" />
            </div>

            <Link to="/schedule" className="flex-1">
              <Button 
                variant="outline"
                size="lg"
                className={cn(
                  "w-full border-2 border-teal-600/20 hover:border-teal-600/40 bg-white/80 hover:bg-teal-50/50 transition-all duration-300 h-12",
                  "group relative overflow-hidden"
                )}
                onMouseEnter={() => setIsHovered(true)}
                onMouseLeave={() => setIsHovered(false)}
              >
                <span className="relative z-10 flex items-center justify-center gap-2 text-teal-700">
                  Schedule an online coffee
                  <Coffee className={cn(
                    "h-4 w-4 transition-all duration-500",
                    isHovered ? "rotate-12 scale-110" : ""
                  )} />
                </span>
              </Button>
            </Link>
          </div>

          <p className="text-sm text-teal-700/70 pt-4">
            No credit card required • 14-day free trial • Full premium access
          </p>
        </div>
      </div>
    </section>
  );
}