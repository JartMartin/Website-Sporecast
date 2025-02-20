import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Store, ArrowRight, AlertTriangle, Loader2, TrendingUp, LineChart } from "lucide-react";
import { useProfile } from "@/hooks/use-profile";
import { useCommodities } from "@/hooks/use-commodities";
import { TypingGreeting } from "@/features/dashboard/shared/components/typing-greeting";
import { EmptyPortfolio } from "@/components/dashboard/empty-portfolio";
import { PortfolioGrid } from "@/components/dashboard/portfolio-grid";
import { PortfolioHeader } from "@/components/dashboard/portfolio-header";
import { StatCard } from "@/components/dashboard/stat-card";

export function DashboardHome() {
  const { profile, loading: profileLoading } = useProfile();
  const { userCommodities, loading: commoditiesLoading } = useCommodities();

  if (profileLoading || commoditiesLoading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 className="h-8 w-8 animate-spin text-teal-600" />
      </div>
    );
  }

  if (userCommodities.length === 0) {
    return (
      <div className="space-y-8">
        <TypingGreeting />
        <EmptyPortfolio />
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <TypingGreeting />

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard 
          title="Active Commodities"
          value={userCommodities.length}
          icon={<Store className="h-6 w-6 text-teal-600" />}
        />
        <StatCard 
          title="Portfolio Value"
          value="€99/mo"
          description={`per commodity`}
          icon={<TrendingUp className="h-6 w-6 text-teal-600" />}
        />
        <StatCard 
          title="Next Billing"
          value={new Date(Date.now() + 15 * 24 * 60 * 60 * 1000).toLocaleDateString()}
          icon={<LineChart className="h-6 w-6 text-teal-600" />}
        />
      </div>

      <div className="space-y-6">
        <PortfolioHeader totalCommodities={userCommodities.length} />
        <PortfolioGrid items={userCommodities} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card className="p-6">
          <h3 className="font-semibold mb-4">Quick Actions</h3>
          <div className="space-y-4">
            <Link to="/dashboard/store">
              <Button variant="outline" className="w-full justify-start gap-2">
                <Store className="h-4 w-4" />
                Browse Commodity Store
              </Button>
            </Link>
            <Link to="/dashboard/alerts">
              <Button variant="outline" className="w-full justify-start gap-2">
                <AlertTriangle className="h-4 w-4" />
                Update Alert Settings
              </Button>
            </Link>
          </div>
        </Card>
      </div>
    </div>
  );
}

export default DashboardHome;