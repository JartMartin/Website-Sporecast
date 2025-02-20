import { useEffect, useState, useRef } from "react";
import { MainNav } from "@/components/navigation/main-nav";
import { HeroSection } from "@/components/landing/hero-section";
import { MarketForecast } from "@/components/landing/market-forecast";
import { ChallengesSection } from "@/components/landing/challenges-section";
import { WhySporecast } from "@/components/landing/why-sporecast";
import { HowItWorks } from "@/components/landing/how-it-works";
import { VisionSection } from "@/components/landing/vision-section";
import { FinalCta } from "@/components/landing/final-cta";
import { Footer } from "@/components/landing/footer";
import { SporaChat } from "@/components/spora-chat";
import { cn } from "@/lib/utils";

export function LandingPage() {
  const [isVisible, setIsVisible] = useState(false);
  const [scrollY, setScrollY] = useState(0);
  const [mousePosition, setMousePosition] = useState({ x: 50, y: 50 });
  const sectionsRef = useRef<(HTMLDivElement | null)[]>([]);

  useEffect(() => {
    setIsVisible(true);

    const handleScroll = () => {
      setScrollY(window.scrollY);

      // Update section visibility based on scroll position
      sectionsRef.current.forEach((section, index) => {
        if (!section) return;
        
        const rect = section.getBoundingClientRect();
        const isInView = rect.top <= window.innerHeight * 0.75;
        
        if (isInView) {
          section.classList.add('animate-in');
        }
      });
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    handleScroll(); // Initial check

    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleMouseMove = (e: React.MouseEvent) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = ((e.clientX - rect.left) / rect.width) * 100;
    const y = ((e.clientY - rect.top) / rect.height) * 100;
    setMousePosition({ x, y });
  };

  return (
    <div className="min-h-screen flex flex-col bg-white">
      <MainNav />

      {/* Hero Section */}
      <div 
        className="relative flex-1 w-full overflow-hidden bg-gradient-to-br from-teal-50 via-emerald-50/50 to-teal-50/30"
        onMouseMove={handleMouseMove}
      >
        {/* Interactive Background */}
        <div className="absolute inset-0 -z-10">
          {/* Grid Pattern */}
          <div 
            className="absolute inset-0 opacity-[0.03]"
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

          {/* Interactive Gradient */}
          <div 
            className="absolute inset-0 opacity-75 transition-opacity duration-500"
            style={{
              background: `
                radial-gradient(
                  circle at ${mousePosition.x}% ${mousePosition.y}%, 
                  rgba(20, 184, 166, 0.15) 0%, 
                  rgba(16, 185, 129, 0.1) 30%, 
                  transparent 70%
                )
              `,
            }}
          />

          {/* Edge Gradients */}
          <div className="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-white to-transparent" />
          <div className="absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-white to-transparent" />
        </div>

        <div className="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 pt-32 pb-16 md:pt-40 md:pb-32">
          <div className="flex flex-col items-center gap-24">
            {/* Hero Content */}
            <HeroSection isVisible={isVisible} />

            {/* Market Forecast */}
            <div className="w-full max-w-5xl mx-auto">
              <MarketForecast isVisible={isVisible} />
            </div>
          </div>
        </div>
      </div>

      {/* Rest of the sections */}
      <div className="relative">
        <div 
          className="absolute inset-0 w-full"
          style={{
            background: 'linear-gradient(180deg, transparent, rgba(16, 185, 129, 0.05) 15%, rgba(13, 148, 136, 0.05) 35%, transparent 65%)',
            transform: `translateY(${scrollY * 0.2}px)`,
            transition: 'transform 0.1s ease-out',
            height: '300vh',
            pointerEvents: 'none',
          }}
        />

        {/* Content Sections */}
        <div 
          ref={el => sectionsRef.current[0] = el}
          className={cn(
            "relative opacity-0 translate-y-4",
            "transition-all duration-1000 ease-out",
            "animate-in:opacity-100 animate-in:translate-y-0"
          )}
        >
          <ChallengesSection />
        </div>

        <div 
          ref={el => sectionsRef.current[1] = el}
          className={cn(
            "relative opacity-0 translate-y-4",
            "transition-all duration-1000 ease-out delay-100",
            "animate-in:opacity-100 animate-in:translate-y-0"
          )}
        >
          <WhySporecast />
        </div>

        <div 
          ref={el => sectionsRef.current[2] = el}
          className={cn(
            "relative opacity-0 translate-y-4",
            "transition-all duration-1000 ease-out delay-200",
            "animate-in:opacity-100 animate-in:translate-y-0"
          )}
        >
          <HowItWorks scrollY={scrollY} />
        </div>

        <div 
          ref={el => sectionsRef.current[3] = el}
          className={cn(
            "relative opacity-0 translate-y-4",
            "transition-all duration-1000 ease-out delay-300",
            "animate-in:opacity-100 animate-in:translate-y-0"
          )}
        >
          <VisionSection />
        </div>

        <div 
          ref={el => sectionsRef.current[4] = el}
          className={cn(
            "relative opacity-0 translate-y-4",
            "transition-all duration-1000 ease-out delay-400",
            "animate-in:opacity-100 animate-in:translate-y-0"
          )}
        >
          <FinalCta />
        </div>
      </div>

      <Footer />
      <SporaChat />
    </div>
  );
}

export default LandingPage;