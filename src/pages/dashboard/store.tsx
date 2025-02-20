import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ChevronLeft, Plus, Search, Loader2 } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/lib/supabase";
import { AddCommodityDialog } from "@/components/dashboard/add-commodity-dialog";

interface Commodity {
  id: string;
  name: string;
  category: string;
  status: "available" | "portfolio" | "coming-soon";
  market_code: string;
  exchange: string;
}

export function CommodityStore() {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCommodity, setSelectedCommodity] = useState<Commodity | null>(null);
  const [commodities, setCommodities] = useState<Commodity[]>([]);
  const [loading, setLoading] = useState(true);
  const { toast } = useToast();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) throw new Error('Not authenticated');

        // Get all commodities
        const { data: allCommodities, error: commoditiesError } = await supabase
          .from('commodities')
          .select('*')
          .order('name');

        if (commoditiesError) throw commoditiesError;

        // Get user's active commodities
        const { data: userCommodities, error: userError } = await supabase
          .from('commodity_portfolio')
          .select('commodity_id')
          .eq('user_id', user.id)
          .eq('status', 'active');

        if (userError) throw userError;

        // Create a Set of user's commodity IDs for faster lookup
        const userCommodityIds = new Set(userCommodities?.map(uc => uc.commodity_id) || []);

        // Map commodities with portfolio status
        const mappedCommodities = allCommodities.map(commodity => ({
          id: commodity.id,
          name: commodity.name,
          category: commodity.category || 'Other',
          market_code: commodity.market_code,
          exchange: commodity.exchange,
          status: userCommodityIds.has(commodity.id)
            ? 'portfolio'
            : commodity.status === 'coming-soon'
              ? 'coming-soon'
              : 'available'
        }));

        setCommodities(mappedCommodities);
      } catch (error: any) {
        console.error('Error fetching commodities:', error);
        toast({
          title: "Error",
          description: error.message,
          variant: "destructive",
        });
      } finally {
        setLoading(false);
      }
    };

    fetchData();

    // Subscribe to portfolio changes
    const subscription = supabase
      .channel('portfolio_changes')
      .on('postgres_changes', { 
        event: '*', 
        schema: 'public', 
        table: 'commodity_portfolio' 
      }, fetchData)
      .subscribe();

    return () => {
      subscription.unsubscribe();
    };
  }, [toast]);

  const filteredCommodities = commodities.filter((commodity) =>
    commodity.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 className="h-8 w-8 animate-spin text-teal-600" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-1">
        <Link
          to="/dashboard"
          className="text-sm text-muted-foreground hover:text-foreground flex items-center gap-1 w-fit"
        >
          <ChevronLeft className="h-4 w-4" /> Back to My Portfolio
        </Link>
        <h1 className="text-3xl font-bold">Commodity Store</h1>
        <p className="text-muted-foreground">
          Browse and add commodities to your portfolio
        </p>
      </div>

      <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
        <div className="relative w-full sm:w-96">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search commodities..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-9"
          />
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-3">
        {filteredCommodities.map((commodity) => (
          <Card key={commodity.id} className="flex flex-col">
            <div className="p-4 flex flex-col h-full">
              <div className="flex items-center justify-between gap-4 mb-3">
                <div className="min-w-0">
                  <h3 className="font-medium truncate">{commodity.name}</h3>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-xs px-1.5 py-0.5 bg-gray-100 rounded">
                      {commodity.market_code}
                    </span>
                    <span className="text-xs text-muted-foreground truncate">
                      {commodity.exchange}
                    </span>
                  </div>
                </div>
                {commodity.status === "coming-soon" && (
                  <span className="flex-shrink-0 text-xs font-medium bg-yellow-100 text-yellow-800 px-1.5 py-0.5 rounded">
                    Soon
                  </span>
                )}
                {commodity.status === "portfolio" && (
                  <span className="flex-shrink-0 text-xs font-medium bg-teal-100 text-teal-800 px-1.5 py-0.5 rounded">
                    Added
                  </span>
                )}
              </div>
              <Button
                className="w-full mt-auto"
                variant={commodity.status === "portfolio" ? "outline" : "default"}
                size="sm"
                disabled={commodity.status !== "available"}
                onClick={() => {
                  if (commodity.status === "available") {
                    setSelectedCommodity(commodity);
                  }
                }}
              >
                {commodity.status === "portfolio"
                  ? "In Portfolio"
                  : commodity.status === "coming-soon"
                  ? "Coming Soon"
                  : "Add to Portfolio"}
              </Button>
            </div>
          </Card>
        ))}
      </div>

      <AddCommodityDialog
        open={!!selectedCommodity}
        onOpenChange={() => setSelectedCommodity(null)}
        commodityId={selectedCommodity?.id || ''}
        commodityName={selectedCommodity?.name || ''}
      />
    </div>
  );
}

export default CommodityStore;