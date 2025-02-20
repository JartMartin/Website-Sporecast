import { cn } from "@/lib/utils";
import { Sprout } from "lucide-react";

interface Loading3DProps {
  size?: "sm" | "md" | "lg";
  className?: string;
}

export function Loading3D({ size = "md", className }: Loading3DProps) {
  return (
    <div className={cn(
      "loader",
      size === "sm" && "loader--sm",
      size === "lg" && "loader--lg",
      className
    )}>
      <div className="box" />
      <div className="box" />
      <div className="box" />
      <div className="box" />
      <div className="box" />
      <div className="logo">
        <Sprout />
      </div>
    </div>
  );
}