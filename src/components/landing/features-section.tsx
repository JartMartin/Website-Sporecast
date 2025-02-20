import { ChartBar, Zap } from "lucide-react";

const features = [
  {
    icon: ChartBar,
    title: "AI-Powered Analysis",
    description: "Advanced machine learning models analyze market trends and patterns.",
  },
  {
    icon: ChartBar,
    title: "Real-time Forecasting",
    description: "Get instant predictions and market insights as conditions change.",
  },
  {
    icon: Zap,
    title: "Quick Integration",
    description: "Easy to use platform that integrates with your existing workflow.",
  },
];

export function FeaturesSection() {
  return (
    <div className="w-full bg-white">
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12 md:py-24">
        <div className="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <div key={index} className="flex flex-col items-start">
                <div className="rounded-lg bg-teal-100 p-3">
                  <Icon className="h-6 w-6 text-teal-600" />
                </div>
                <h3 className="mt-6 text-lg font-semibold">{feature.title}</h3>
                <p className="mt-2 text-gray-600">{feature.description}</p>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}