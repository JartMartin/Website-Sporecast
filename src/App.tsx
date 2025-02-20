import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { Toaster } from "@/components/ui/toaster";
import { Suspense, lazy } from "react";
import { LoadingPage } from "@/components/ui/loading-page";

// Lazy load pages
const LandingPage = lazy(() => import("@/pages/landing"));
const FeaturesPage = lazy(() => import("@/pages/features"));
const PricingPage = lazy(() => import("@/pages/pricing"));
const StoryPage = lazy(() => import("@/pages/story"));
const CommoditiesPage = lazy(() => import("@/pages/commodities"));
const SchedulePage = lazy(() => import("@/pages/schedule"));
const ComingSoonPage = lazy(() => import("@/pages/coming-soon"));

export default function App() {
  return (
    <Router>
      <Suspense fallback={<LoadingPage />}>
        <Routes>
          {/* Public routes */}
          <Route path="/" element={<LandingPage />} />
          <Route path="/features" element={<FeaturesPage />} />
          <Route path="/pricing" element={<PricingPage />} />
          <Route path="/story" element={<StoryPage />} />
          <Route path="/commodities" element={<CommoditiesPage />} />
          <Route path="/schedule" element={<SchedulePage />} />
          
          {/* Auth routes redirect to coming soon */}
          <Route path="/auth" element={<ComingSoonPage />} />
          
          {/* Catch all other routes */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Suspense>
      <Toaster />
    </Router>
  );
}

export { App };