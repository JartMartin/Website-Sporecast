import { useState, useEffect } from "react";
import { Card } from "@/components/ui/card";
import { CommodityOverview } from "./components/commodity-overview";
import { UnsubscribeButton } from "./components/unsubscribe-button";
import { UnsubscribeDialog } from "@/components/dashboard/unsubscribe-dialog";
import { WheatPlotlyChart } from "@/components/dashboard/wheat-plotly-chart";
import { supabase } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";
import { Loader2 } from "lucide-react";

interface WheatOverview {
  current_price: number;
  price_change: number;
  percent_change: number;
  last_update: string;
}

export function WheatPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [overview, setOverview] = useState<WheatOverview | null>(null);
  const [showUnsubscribe, setShowUnsubscribe] = useState(false);
  const { toast } = useToast();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const { data: wheatId } = await supabase
          .from('commodities')
          .select('id')
          .eq('symbol', 'WHEAT')
          .single();

        if (!wheatId) throw new Error('Wheat commodity not found');

        const { data, error } = await supabase
          .from('wheat_forecasts')
          .select('*')
          .eq('commodity_id', wheatId.id)
          .order('date', { ascending: true })
          .limit(2);

        if (error) throw error;

        if (!data || data.length < 2) {
          throw new Error("Insufficient data in the wheat_forecasts table.");
        }

        // Set overview data
        const latestData = data[data.length - 1];
        const previousData = data[data.length - 2];
        setOverview({
          current_price: latestData.price,
          price_change: latestData.price - previousData.price,
          percent_change: ((latestData.price - previousData.price) / previousData.price) * 100,
          last_update: latestData.created_at,
        });
      } catch (err: any) {
        setError(err.message);
        toast({
          title: "Error",
          description: "Failed to load wheat data.",
          variant: "destructive",
        });
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [toast]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 className="h-8 w-8 animate-spin text-teal-600" />
      </div>
    );
  }

  if (error || !overview) {
    return (
      <div className="text-center text-red-500">
        Failed to load wheat data. Please try again later.
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <CommodityOverview
        name="Wheat Futures"
        exchange="Chicago Board of Trade (CBOT)"
        marketCode="ZW"
        currentPrice={overview.current_price}
        priceChange={overview.price_change}
        percentChange={overview.percent_change}
        lastUpdate={new Date(overview.last_update)}
      />

      <WheatPlotlyChart />

      <UnsubscribeButton onClick={() => setShowUnsubscribe(true)} />
      <UnsubscribeDialog
        open={showUnsubscribe}
        onOpenChange={setShowUnsubscribe}
        commodityName="Wheat"
        commodityId="wheat-id"
      />
    </div>
  );
}

export default WheatPage;