import { MainNav } from "@/components/navigation/main-nav";
import { CommodityTable } from "@/components/commodities/commodity-table";
import { SporaChat } from "@/components/spora-chat";
import { Footer } from "@/components/landing/footer";

// Mock data for commodities
const commoditiesData = [
  {
    name: "Milling Wheat / Blé de Meunerie",
    category: "Cereals",
    exchange: "Euronext",
    marketCode: "EBM",
    status: "available" as const,
  },
  {
    name: "Corn / Maize",
    category: "Cereals",
    exchange: "Chicago Mercantile Exchange (CME)",
    marketCode: "ZC",
    status: "available" as const,
  },
  {
    name: "Barley",
    category: "Cereals",
    exchange: "Euronext",
    marketCode: "BAR",
    status: "coming-soon" as const,
  },
  {
    name: "Oats",
    category: "Cereals",
    exchange: "Chicago Mercantile Exchange (CME)",
    marketCode: "ZO",
    status: "in-queue" as const,
  },
  {
    name: "Soybean",
    category: "Oilseeds",
    exchange: "Chicago Mercantile Exchange (CME)",
    marketCode: "ZS",
    status: "coming-soon" as const,
  }
];

export function CommoditiesPage() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <MainNav />

      <main className="flex-1 pt-32 pb-12 md:pt-40 md:pb-24">
        <div className="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Header Section */}
          <div className="max-w-3xl mx-auto text-center space-y-8 mb-16">
            <h1 className="text-4xl font-bold tracking-tight">
              <span className="text-gray-900">Stay Ahead of </span>
              <span className="relative inline-block">
                <span className="absolute -inset-2 rounded-lg bg-gradient-to-r from-teal-500/20 to-emerald-500/20 blur-lg" />
                <span className="relative bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
                  Food Commodity Markets
                </span>
              </span>
            </h1>
            <p className="text-xl text-gray-600">
              Track our growing list of supported commodities and see what's coming next. We're continuously expanding our coverage to help you make better procurement decisions.
            </p>
          </div>

          {/* Commodity Table */}
          <CommodityTable commodities={commoditiesData} />
        </div>
      </main>

      <Footer />
      <SporaChat />
    </div>
  );
}

export default CommoditiesPage;