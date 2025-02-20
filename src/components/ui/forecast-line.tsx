import { useEffect, useRef, useState } from 'react';
import { cn } from '@/lib/utils';

interface Point {
  x: number;
  y: number;
  value: number;
  date: Date;
  isHistorical: boolean;
}

export function ForecastLine() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [mousePos, setMousePos] = useState<Point | null>(null);
  const [isHovering, setIsHovering] = useState(false);
  const [tooltip, setTooltip] = useState<{
    show: boolean;
    x: number;
    y: number;
    value: number;
    date: Date;
    isHistorical: boolean;
    confidence?: { lower: number; upper: number };
  } | null>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Set up high DPI canvas
    const dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    ctx.scale(dpr, dpr);
    canvas.style.width = `${rect.width}px`;
    canvas.style.height = `${rect.height}px`;

    // Animation setup
    let animationFrame: number;
    let progress = 0;
    const duration = 2000; // 2 seconds
    const startTime = performance.now();

    // Generate data points with increased volatility
    const generatePoints = (): Point[] => {
      const points: Point[] = [];
      const width = rect.width;
      const height = rect.height;
      const today = new Date();
      const monthsBack = 6;
      const monthsForward = 12;
      const totalMonths = monthsBack + monthsForward;
      const pointsPerMonth = 8; // Increased for more detail
      const totalPoints = totalMonths * pointsPerMonth;
      
      for (let i = 0; i < totalPoints; i++) {
        const x = (i / totalPoints) * width;
        const monthOffset = -monthsBack + (i / pointsPerMonth);
        const date = new Date(today);
        date.setMonth(date.getMonth() + monthOffset);
        
        const isHistorical = monthOffset <= 0;
        
        // Increased volatility for both historical and forecast data
        const baseValue = 200;
        const trend = Math.sin(i * 0.3) * 25; // Increased amplitude
        const volatility = isHistorical ? 
          Math.sin(i * 0.8) * 15 + Math.cos(i * 1.2) * 10 : // More complex historical pattern
          Math.sin(i * 0.6) * 20 + Math.cos(i * 0.9) * 15;  // More volatile forecast
        
        const value = baseValue + trend + volatility;
        const y = height / 2 - ((value - baseValue) * 2);
        
        points.push({ x, y, value, date, isHistorical });
      }
      return points;
    };

    const allPoints = generatePoints();
    const transitionPoint = allPoints.findIndex(p => !p.isHistorical);

    const drawLine = (points: Point[], progress: number, isHistorical: boolean) => {
      if (points.length < 2) return;

      ctx.beginPath();
      ctx.moveTo(points[0].x, points[0].y);

      const pointsToDraw = Math.ceil(points.length * progress);
      
      for (let i = 1; i < pointsToDraw; i++) {
        const curr = points[i];
        const prev = points[i - 1];
        
        // Smooth curve with tighter control points for more dramatic changes
        const cp1x = prev.x + (curr.x - prev.x) / 4;
        const cp1y = prev.y;
        const cp2x = curr.x - (curr.x - prev.x) / 4;
        const cp2y = curr.y;
        
        ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, curr.x, curr.y);
      }

      if (isHistorical) {
        ctx.strokeStyle = '#0d9488';
        ctx.setLineDash([]);
      } else {
        const gradient = ctx.createLinearGradient(points[0].x, 0, points[points.length - 1].x, 0);
        gradient.addColorStop(0, '#0d9488');
        gradient.addColorStop(1, '#10b981');
        ctx.strokeStyle = gradient;
        ctx.setLineDash([5, 5]);
      }
      
      ctx.lineWidth = 2;
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';
      ctx.stroke();
    };

    const drawConfidenceInterval = (points: Point[], progress: number) => {
      const intervals = [
        { opacity: 0.05, range: 60 }, // Wider 90% CI
        { opacity: 0.1, range: 30 }   // Wider 66% CI
      ];
      
      intervals.forEach(({ opacity, range }) => {
        ctx.beginPath();
        
        // Upper bound with added volatility
        points.forEach((point, i) => {
          const volatilityOffset = Math.sin(i * 0.4) * 10;
          if (i === 0) ctx.moveTo(point.x, point.y - range + volatilityOffset);
          else ctx.lineTo(point.x, point.y - range + volatilityOffset);
        });
        
        // Lower bound with added volatility
        [...points].reverse().forEach((point, i) => {
          const volatilityOffset = Math.sin(i * 0.4) * 10;
          ctx.lineTo(point.x, point.y + range + volatilityOffset);
        });
        
        ctx.closePath();
        ctx.fillStyle = `rgba(13, 148, 136, ${opacity * progress})`;
        ctx.fill();
      });
    };

    const drawGrid = (ctx: CanvasRenderingContext2D, width: number, height: number) => {
      ctx.strokeStyle = 'rgba(229, 231, 235, 0.3)';
      ctx.lineWidth = 1;
      
      // Vertical lines (months)
      const monthWidth = width / 18;
      for (let i = 0; i <= 18; i++) {
        const x = i * monthWidth;
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, height);
        ctx.stroke();
      }
      
      // Horizontal lines
      const step = height / 8;
      for (let i = 0; i <= 8; i++) {
        const y = i * step;
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(width, y);
        ctx.stroke();
      }
    };

    const drawHoverEffect = (point: Point) => {
      // Glow effect
      const gradient = ctx.createRadialGradient(
        point.x, point.y, 0,
        point.x, point.y, 25
      );
      gradient.addColorStop(0, 'rgba(13, 148, 136, 0.15)');
      gradient.addColorStop(1, 'rgba(13, 148, 136, 0)');
      
      ctx.fillStyle = gradient;
      ctx.beginPath();
      ctx.arc(point.x, point.y, 25, 0, Math.PI * 2);
      ctx.fill();
      
      // Data point
      ctx.beginPath();
      ctx.arc(point.x, point.y, 4, 0, Math.PI * 2);
      ctx.fillStyle = point.isHistorical ? '#0d9488' : '#10b981';
      ctx.fill();
      ctx.strokeStyle = 'white';
      ctx.lineWidth = 2;
      ctx.stroke();
    };

    const animate = (currentTime: number) => {
      const elapsed = currentTime - startTime;
      progress = Math.min(elapsed / duration, 1);

      ctx.clearRect(0, 0, canvas.width, canvas.height);
      
      // Draw grid
      drawGrid(ctx, rect.width, rect.height);
      
      // Draw historical data
      const historicalPoints = allPoints.slice(0, transitionPoint);
      const historicalProgress = Math.min(progress * 2, 1);
      drawLine(historicalPoints, historicalProgress, true);
      
      // Draw forecast data
      if (progress > 0.5) {
        const forecastPoints = allPoints.slice(transitionPoint);
        const forecastProgress = (progress - 0.5) * 2;
        drawConfidenceInterval(forecastPoints, forecastProgress);
        drawLine(forecastPoints, forecastProgress, false);
      }
      
      // Draw hover effects
      if (mousePos && isHovering) {
        drawHoverEffect(mousePos);
      }

      if (progress < 1) {
        animationFrame = requestAnimationFrame(animate);
      }
    };

    animationFrame = requestAnimationFrame(animate);

    return () => cancelAnimationFrame(animationFrame);
  }, []);

  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    // Find closest point with increased volatility
    const today = new Date();
    const monthOffset = -6 + (x / rect.width * 18);
    const date = new Date(today);
    date.setMonth(date.getMonth() + monthOffset);
    
    const isHistorical = monthOffset <= 0;
    const baseValue = 200;
    const volatility = isHistorical ? 
      Math.sin(x * 0.1) * 25 : 
      Math.sin(x * 0.08) * 35;
    const value = baseValue + volatility;
    
    const point = { x, y, value, date, isHistorical };
    setMousePos(point);
    
    const confidence = !isHistorical ? {
      lower: Math.round(value - 20),
      upper: Math.round(value + 20)
    } : undefined;
    
    setTooltip({
      show: true,
      x: e.clientX,
      y: e.clientY,
      value: Math.round(value),
      date,
      isHistorical,
      confidence
    });
  };

  const handleMouseLeave = () => {
    setMousePos(null);
    setIsHovering(false);
    setTooltip(null);
  };

  const handleMouseEnter = () => {
    setIsHovering(true);
  };

  return (
    <div className="relative w-full h-full">
      <canvas
        ref={canvasRef}
        className="w-full h-full cursor-crosshair"
        onMouseMove={handleMouseMove}
        onMouseLeave={handleMouseLeave}
        onMouseEnter={handleMouseEnter}
      />
      {tooltip && (
        <div
          className={cn(
            "absolute pointer-events-none bg-white/95 p-3 rounded-lg shadow-lg border",
            "backdrop-blur-sm transform -translate-x-1/2 -translate-y-full",
            "transition-all duration-200",
            tooltip.show ? "opacity-100 translate-y-0" : "opacity-0 translate-y-2"
          )}
          style={{
            left: tooltip.x,
            top: tooltip.y - 10
          }}
        >
          <div className="text-sm font-medium">
            {tooltip.date.toLocaleDateString('en-US', { 
              month: 'short',
              year: 'numeric'
            })}
          </div>
          <div className={cn(
            "font-semibold",
            tooltip.isHistorical ? "text-teal-600" : "text-emerald-600"
          )}>
            €{tooltip.value}
          </div>
          {tooltip.confidence && (
            <div className="text-xs text-muted-foreground">
              CI: €{tooltip.confidence.lower} - €{tooltip.confidence.upper}
            </div>
          )}
        </div>
      )}
    </div>
  );
}