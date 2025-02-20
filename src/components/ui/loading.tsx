import { Sprout } from "lucide-react";
import { cn } from "@/lib/utils";

interface LoadingProps {
  className?: string;
  size?: "sm" | "md" | "lg";
}

export function Loading({ className, size = "md" }: LoadingProps) {
  const sizeClass = {
    sm: "w-32 h-32",
    md: "w-48 h-48",
    lg: "w-64 h-64"
  }[size];

  return (
    <div className={cn("loader", sizeClass, className)}>
      <div className="box"></div>
      <div className="box"></div>
      <div className="box"></div>
      <div className="box"></div>
      <div className="box"></div>
      <div className="logo">
        <Sprout className="h-full w-full" />
      </div>
    </div>
  );
}