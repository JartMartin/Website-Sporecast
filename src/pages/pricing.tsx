import { useState } from "react";
import { Link } from "react-router-dom";
import { MainNav } from "@/components/navigation/main-nav";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Coffee, ArrowRight, Plus, Minus, Calculator, Users, Gift, Trash2 } from "lucide-react";
import { SporaChat } from "@/components/spora-chat";
import { Footer } from "@/components/landing/footer";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { cn } from "@/lib/utils";

interface CommoditySelection {
  id: string;
  name: string;
  userCount: number;
}

const availableCommodities = [
  { id: "wheat", name: "Wheat" },
  { id: "coffee", name: "Coffee" },
  { id: "soy", name: "Soybean" },
  { id: "corn", name: "Corn" },
  { id: "barley", name: "Barley" },
];

const faqs = [
  {
    question: "What does all access include?",
    answer: "All access includes every feature available for your selected commodity: real-time forecasts, market analysis, custom alerts, historical data, API access, and priority support. There are no feature restrictions or hidden tiers."
  },
  {
    question: "What is the minimum subscription period?",
    answer: "Each commodity requires a minimum subscription period of 52 weeks (1 year). This is billed annually to ensure you get the most value from our long-term forecasting capabilities."
  },
  {
    question: "Can I cancel anytime?",
    answer: "Yes, you can cancel your subscription at any time. You'll continue to have access until the end of your current billing period. Note that subscriptions are annual and non-refundable."
  },
  {
    question: "How does the free trial work?",
    answer: "Each commodity comes with a 5-day free trial to explore the forecasts."
  },
  {
    question: "Can I add more commodities later?",
    answer: "Yes, you can add or remove commodities from your portfolio at any time through our Commodity Store after registration. Each new commodity comes with a 5-day free trial."
  }
];

export function PricingPage() {
  const [isHovered, setIsHovered] = useState(false);
  const [selectedCommodities, setSelectedCommodities] = useState<CommoditySelection[]>([
    { id: "wheat", name: "Wheat", userCount: 1 }
  ]);
  const [commodityToDelete, setCommodityToDelete] = useState<number | null>(null);

  const getPricePerUser = (userCount: number) => {
    if (userCount >= 5) return 89;
    if (userCount >= 2) return 109;
    return 129;
  };

  const calculateMonthlyPrice = () => {
    return selectedCommodities.reduce((total, commodity) => {
      const pricePerUser = getPricePerUser(commodity.userCount);
      return total + (pricePerUser * commodity.userCount);
    }, 0);
  };

  const addCommodity = () => {
    const availableOptions = availableCommodities.filter(
      commodity => !selectedCommodities.find(selected => selected.id === commodity.id)
    );
    
    if (availableOptions.length > 0) {
      setSelectedCommodities([
        ...selectedCommodities,
        { id: availableOptions[0].id, name: availableOptions[0].name, userCount: 1 }
      ]);
    }
  };

  const handleRemoveCommodity = (index: number) => {
    setCommodityToDelete(index);
  };

  const confirmRemoveCommodity = () => {
    if (commodityToDelete !== null) {
      setSelectedCommodities(prev => prev.filter((_, i) => i !== commodityToDelete));
      setCommodityToDelete(null);
    }
  };

  const updateUserCount = (index: number, change: number) => {
    setSelectedCommodities(prev => prev.map((item, i) => {
      if (i === index) {
        const newCount = Math.max(1, item.userCount + change);
        return { ...item, userCount: newCount };
      }
      return item;
    }));
  };

  const updateCommodity = (index: number, commodityId: string) => {
    setSelectedCommodities(prev => prev.map((item, i) => {
      if (i === index) {
        const commodity = availableCommodities.find(c => c.id === commodityId);
        return { ...item, id: commodityId, name: commodity?.name || item.name };
      }
      return item;
    }));
  };

  const monthlyPrice = calculateMonthlyPrice();
  const annualPrice = monthlyPrice * 12;

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <MainNav />

      <main className="flex-1">
        <div className="relative pt-32 pb-12 md:pt-40 md:pb-24">
          {/* Background Pattern */}
          <div className="absolute inset-0 -z-10">
            <div className="absolute inset-0 bg-gradient-to-br from-teal-50 via-white to-emerald-50" />
            <svg
              className="absolute w-full h-full opacity-[0.15]"
              xmlns="http://www.w3.org/2000/svg"
            >
              <defs>
                <pattern
                  id="pricing-grid"
                  width="32"
                  height="32"
                  patternUnits="userSpaceOnUse"
                >
                  <path d="M0 32V0h32" fill="none" stroke="currentColor" strokeOpacity="0.2" />
                </pattern>
              </defs>
              <rect width="100%" height="100%" fill="url(#pricing-grid)" />
            </svg>
          </div>

          <div className="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="max-w-3xl mx-auto text-center space-y-8">
              <h1 className="text-4xl md:text-5xl font-bold tracking-tight">
                Simple, Transparent{" "}
                <span className="bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
                  Pricing
                </span>
              </h1>
              <p className="text-xl text-gray-600">
                €99 per commodity per month (excl. VAT), billed annually. All access, no hidden fees.
              </p>

              {/* Pricing Tiers */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                <div className="bg-white rounded-lg p-4 shadow-sm border">
                  <div className="font-medium">1 User</div>
                  <div className="text-lg font-bold mt-1">€129/month</div>
                  <div className="text-xs text-gray-500">per commodity (excl. VAT)</div>
                </div>
                <div className="bg-white rounded-lg p-4 shadow-sm border border-teal-200">
                  <div className="font-medium">2-4 Users</div>
                  <div className="text-lg font-bold mt-1">€109/month</div>
                  <div className="text-xs text-gray-500">per user, per commodity (excl. VAT)</div>
                </div>
                <div className="bg-white rounded-lg p-4 shadow-sm border">
                  <div className="font-medium">5+ Users</div>
                  <div className="text-lg font-bold mt-1">€89/month</div>
                  <div className="text-xs text-gray-500">per user, per commodity (excl. VAT)</div>
                </div>
              </div>
            </div>

            {/* Pricing Calculator */}
            <div className="mt-16 max-w-3xl mx-auto">
              <Card className="p-8">
                <div className="space-y-8">
                  {/* Calculator Header */}
                  <div className="flex items-center gap-3 pb-4 border-b">
                    <div className="h-10 w-10 rounded-lg bg-teal-50 flex items-center justify-center">
                      <Calculator className="h-5 w-5 text-teal-600" />
                    </div>
                    <div>
                      <h2 className="font-semibold text-lg">Pricing Calculator</h2>
                      <p className="text-sm text-muted-foreground">
                        Select commodities and adjust user count to calculate your price
                      </p>
                    </div>
                  </div>

                  {/* Commodity Selections */}
                  <div className="space-y-4">
                    {selectedCommodities.map((commodity, index) => (
                      <div key={index} className="space-y-2">
                        <div className="flex items-center gap-4">
                          <div className="flex-1">
                            <Select
                              value={commodity.id}
                              onValueChange={(value) => updateCommodity(index, value)}
                            >
                              <SelectTrigger>
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                {availableCommodities
                                  .filter(c => 
                                    c.id === commodity.id || 
                                    !selectedCommodities.find(selected => selected.id === c.id)
                                  )
                                  .map(c => (
                                    <SelectItem key={c.id} value={c.id}>
                                      {c.name}
                                    </SelectItem>
                                  ))
                                }
                              </SelectContent>
                            </Select>
                          </div>

                          <div className="flex items-center gap-2">
                            <Label className="text-sm text-muted-foreground">Users:</Label>
                            <div className="flex items-center gap-2">
                              <Button
                                variant="outline"
                                size="icon"
                                className="h-8 w-8"
                                onClick={() => updateUserCount(index, -1)}
                                disabled={commodity.userCount <= 1}
                              >
                                <Minus className="h-4 w-4" />
                              </Button>
                              <Input
                                type="number"
                                value={commodity.userCount}
                                onChange={(e) => {
                                  const count = Math.max(1, parseInt(e.target.value) || 1);
                                  updateUserCount(index, count - commodity.userCount);
                                }}
                                className="w-16 text-center h-8"
                              />
                              <Button
                                variant="outline"
                                size="icon"
                                className="h-8 w-8"
                                onClick={() => updateUserCount(index, 1)}
                              >
                                <Plus className="h-4 w-4" />
                              </Button>
                            </div>
                          </div>

                          <div className="w-32 text-right">
                            €{getPricePerUser(commodity.userCount)} per user
                          </div>

                          {selectedCommodities.length > 1 && (
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8 text-gray-400 hover:text-red-600 hover:bg-red-50"
                              onClick={() => handleRemoveCommodity(index)}
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          )}
                        </div>

                        {/* Free Days Highlight */}
                        <div className="flex items-center gap-2 text-xs text-teal-600">
                          <Gift className="h-3.5 w-3.5" />
                          <span>5 free days to explore this commodity's forecasts</span>
                        </div>
                      </div>
                    ))}
                  </div>

                  {/* Add Commodity Button */}
                  {selectedCommodities.length < availableCommodities.length && (
                    <Button
                      variant="outline"
                      className="w-full gap-2"
                      onClick={addCommodity}
                    >
                      <Plus className="h-4 w-4" />
                      Add Another Commodity
                    </Button>
                  )}

                  {/* Volume Discount Notice */}
                  <div className="flex items-center gap-2 p-3 bg-teal-50 rounded-lg text-sm text-teal-700">
                    <Users className="h-4 w-4 flex-shrink-0" />
                    <p>
                      You can add extra accounts and commodities at any time. The volume-based discount structure will continue to apply as your team grows.
                    </p>
                  </div>

                  {/* Price Breakdown */}
                  <div className="space-y-4 pt-4 border-t">
                    {selectedCommodities.map((commodity, index) => (
                      <div key={index} className="flex justify-between text-sm">
                        <span className="text-gray-600">
                          {commodity.name}: {commodity.userCount} user{commodity.userCount > 1 ? 's' : ''} × €{getPricePerUser(commodity.userCount)}
                        </span>
                        <span className="font-medium">
                          €{(commodity.userCount * getPricePerUser(commodity.userCount)).toLocaleString()}/month
                        </span>
                      </div>
                    ))}
                  </div>

                  {/* Total Price */}
                  <div className="pt-4 border-t space-y-2">
                    <div className="flex justify-between items-baseline">
                      <span className="text-lg font-medium">Total (excl. VAT)</span>
                      <div className="text-right">
                        <div className="text-2xl font-bold">
                          €{monthlyPrice.toLocaleString()}/month
                        </div>
                        <div className="text-sm text-gray-500">
                          Billed annually at €{annualPrice.toLocaleString()}
                        </div>
                      </div>
                    </div>
                  </div>

                  <Link to="/auth?tab=signup" className="block">
                    <Button className="w-full group" size="lg">
                      <span className="flex items-center gap-2">
                        Start Free Trial
                        <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                      </span>
                    </Button>
                  </Link>

                  <p className="text-sm text-center text-muted-foreground">
                    5-day free trial per commodity
                  </p>
                </div>
              </Card>
            </div>

            {/* FAQs */}
            <div className="mt-16 max-w-3xl mx-auto">
              <h2 className="text-2xl font-bold text-center mb-8">
                Frequently Asked Questions
              </h2>
              <Accordion type="single" collapsible className="w-full">
                {faqs.map((faq, index) => (
                  <AccordionItem key={index} value={`item-${index}`}>
                    <AccordionTrigger className="text-left">
                      {faq.question}
                    </AccordionTrigger>
                    <AccordionContent>
                      {faq.answer}
                    </AccordionContent>
                  </AccordionItem>
                ))}
              </Accordion>
            </div>

            {/* Additional CTA Section */}
            <div className="mt-16 max-w-2xl mx-auto text-center space-y-8">
              <h2 className="text-2xl font-bold">Still have questions or concerns?</h2>
              <p className="text-gray-600">
                Chat with Spora for any questions about our platform, payments, or methodology. Prefer a personal discussion? Schedule an online coffee with our team!
              </p>
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4 justify-center">
                <Link to="/schedule">
                  <Button 
                    variant="outline"
                    size="lg"
                    className={cn(
                      "gap-2 border-2 border-teal-600/20 hover:border-teal-600/40 bg-white hover:bg-teal-50/50 transition-all duration-300",
                      "group relative overflow-hidden"
                    )}
                    onMouseEnter={() => setIsHovered(true)}
                    onMouseLeave={() => setIsHovered(false)}
                  >
                    <Coffee className={cn(
                      "h-4 w-4 transition-all duration-500",
                      isHovered ? "rotate-12 scale-110" : ""
                    )} />
                    Schedule an online coffee
                  </Button>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </main>

      <Footer />
      <SporaChat />

      {/* Delete Confirmation Dialog */}
      <AlertDialog 
        open={commodityToDelete !== null} 
        onOpenChange={() => setCommodityToDelete(null)}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Remove Commodity</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to remove this commodity from your selection?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction 
              onClick={confirmRemoveCommodity}
              className="bg-red-600 hover:bg-red-700"
            >
              Remove
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

export default PricingPage;