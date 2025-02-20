import { useEffect, useRef, useState } from "react";

interface Node {
  x: number;
  y: number;
  connections: number[];
  speed: number;
  offset: number;
}

interface NeuralNetworkProps {
  width?: number;
  height?: number;
  nodeCount?: number;
  color?: string;
}

export function NeuralNetwork({ 
  width = 300, 
  height = 300, 
  nodeCount = 12,
  color = "rgb(13, 148, 136)"
}: NeuralNetworkProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [time, setTime] = useState(0);
  const animationFrameRef = useRef<number>();
  const drawIntervalRef = useRef<number>();

  // Generate nodes
  const nodes = useRef<Node[]>(Array.from({ length: nodeCount }, (_, i) => ({
    x: Math.sin(i * Math.PI * 2 / nodeCount) * (width * 0.4) + width/2,
    y: Math.cos(i * Math.PI * 2 / nodeCount) * (height * 0.4) + height/2,
    connections: [],
    speed: 0.2 + Math.random() * 0.3,
    offset: Math.random() * Math.PI * 2,
  }))).current;

  // Create random connections
  useEffect(() => {
    nodes.forEach((node, i) => {
      const numConnections = 2 + Math.floor(Math.random() * 3);
      for (let j = 0; j < numConnections; j++) {
        const target = Math.floor(Math.random() * nodes.length);
        if (target !== i && !node.connections.includes(target)) {
          node.connections.push(target);
        }
      }
    });
  }, [nodes]);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let lastTime = performance.now();
    const animate = (currentTime: number) => {
      const deltaTime = (currentTime - lastTime) / 1000;
      lastTime = currentTime;
      
      setTime(t => t + deltaTime);
      animationFrameRef.current = requestAnimationFrame(animate);
    };

    const draw = () => {
      if (!canvas || !ctx) return;

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      nodes.forEach((node, i) => {
        const t = time * node.speed + node.offset;
        const x = node.x + Math.sin(t) * 20;
        const y = node.y + Math.cos(t) * 20;

        // Draw connections
        ctx.beginPath();
        node.connections.forEach(targetIndex => {
          const target = nodes[targetIndex];
          const targetT = time * target.speed + target.offset;
          const targetX = target.x + Math.sin(targetT) * 20;
          const targetY = target.y + Math.cos(targetT) * 20;

          ctx.moveTo(x, y);
          ctx.lineTo(targetX, targetY);
        });
        ctx.strokeStyle = color.replace('rgb', 'rgba').replace(')', ', 0.2)');
        ctx.lineWidth = 1;
        ctx.stroke();

        // Draw node
        ctx.beginPath();
        ctx.arc(x, y, 4, 0, Math.PI * 2);
        ctx.fillStyle = color.replace('rgb', 'rgba').replace(')', ', 0.4)');
        ctx.fill();
      });
    };

    // Start animation
    animationFrameRef.current = requestAnimationFrame(animate);
    
    // Set up draw interval
    const drawInterval = setInterval(draw, 16);
    drawIntervalRef.current = drawInterval;

    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
      if (drawIntervalRef.current) {
        clearInterval(drawIntervalRef.current);
      }
    };
  }, [time, nodes, color]);

  return (
    <canvas
      ref={canvasRef}
      width={width}
      height={height}
      className="opacity-50"
    />
  );
}