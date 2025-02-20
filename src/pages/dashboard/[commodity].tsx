import { useParams, Navigate } from 'react-router-dom';
import { CommodityPage } from '@/components/dashboard/commodity-page';
import { useCommodities } from '@/hooks/use-commodities';
import { Loader2 } from 'lucide-react';

export function DynamicCommodityPage() {
  const { commodity } = useParams();
  const { loading, userCommodities } = useCommodities();

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 className="h-8 w-8 animate-spin text-teal-600" />
      </div>
    );
  }

  // Find the commodity in user's portfolio
  const commodityData = userCommodities.find(
    c => c.name.toLowerCase() === commodity?.toLowerCase()
  );

  // If commodity is not in user's portfolio, redirect to dashboard
  if (!commodityData) {
    return <Navigate to="/dashboard" replace />;
  }

  return (
    <CommodityPage
      name={commodityData.name}
      commodityId={commodityData.id}
    />
  );
}

export default DynamicCommodityPage;