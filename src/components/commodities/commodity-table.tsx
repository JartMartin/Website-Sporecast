import { useState } from "react";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { cn } from "@/lib/utils";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Search, Plus, Bell } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

const exchanges = [
  { value: "all", label: "All Exchanges" },
  { value: "cme", label: "Chicago Mercantile Exchange (CME)" },
  { value: "euronext", label: "Euronext" },
  { value: "ice", label: "Intercontinental Exchange (ICE)" },
];

const categories = [
  { value: "all", label: "All Categories" },
  { value: "cereals", label: "Cereals" },
  { value: "oilseeds", label: "Oilseeds" },
  { value: "other", label: "Other" },
];

interface Commodity {
  name: string;
  category: string;
  exchange: string;
  marketCode: string;
  status: "available" | "coming-soon" | "in-queue";
}

interface CommodityTableProps {
  commodities: Commodity[];
}

export function CommodityTable({ commodities }: CommodityTableProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedExchange, setSelectedExchange] = useState("all");
  const [selectedCategory, setSelectedCategory] = useState("all");
  const [showRequestForm, setShowRequestForm] = useState(false);
  const [showNotifyForm, setShowNotifyForm] = useState(false);
  const [selectedCommodity, setSelectedCommodity] = useState<Commodity | null>(null);
  const [requestFormData, setRequestFormData] = useState({
    name: "",
    company: "",
    email: "",
    phone: "",
    commodityName: "",
    marketCode: "",
    exchange: "",
    details: ""
  });
  const [notifyFormData, setNotifyFormData] = useState({
    name: "",
    company: "",
    email: "",
    phone: "",
  });
  const { toast } = useToast();

  const handleRequestSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setShowRequestForm(false);
    setRequestFormData({
      name: "",
      company: "",
      email: "",
      phone: "",
      commodityName: "",
      marketCode: "",
      exchange: "",
      details: ""
    });
    toast({
      title: "Request Submitted",
      description: "Thank you! Your commodity request has been submitted for review.",
    });
  };

  const handleNotifySubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setShowNotifyForm(false);
    setSelectedCommodity(null);
    setNotifyFormData({
      name: "",
      company: "",
      email: "",
      phone: "",
    });
    toast({
      title: "Notification Set",
      description: `We'll notify you when ${selectedCommodity?.name} becomes available.`,
    });
  };

  // Filter commodities based on search, exchange, and category
  const filteredCommodities = commodities.filter((commodity) => {
    const matchesSearch = commodity.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         commodity.marketCode.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesExchange = selectedExchange === "all" || 
                           commodity.exchange.toLowerCase().includes(selectedExchange);
    const matchesCategory = selectedCategory === "all" || 
                           commodity.category.toLowerCase() === selectedCategory;
    return matchesSearch && matchesExchange && matchesCategory;
  });

  return (
    <Card className="p-6">
      <div className="space-y-6">
        {/* Filters */}
        <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
          <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center flex-1">
            {/* Search */}
            <div className="relative w-full sm:w-96">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search commodities..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9"
              />
            </div>

            {/* Category Filter */}
            <Select
              value={selectedCategory}
              onValueChange={setSelectedCategory}
            >
              <SelectTrigger className="w-full sm:w-[180px]">
                <SelectValue placeholder="Select category" />
              </SelectTrigger>
              <SelectContent>
                {categories.map((category) => (
                  <SelectItem key={category.value} value={category.value}>
                    {category.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {/* Exchange Filter */}
            <Select
              value={selectedExchange}
              onValueChange={setSelectedExchange}
            >
              <SelectTrigger className="w-full sm:w-[200px]">
                <SelectValue placeholder="Select exchange" />
              </SelectTrigger>
              <SelectContent>
                {exchanges.map((exchange) => (
                  <SelectItem key={exchange.value} value={exchange.value}>
                    {exchange.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Request Button */}
          <Dialog open={showRequestForm} onOpenChange={setShowRequestForm}>
            <DialogTrigger asChild>
              <Button className="gap-2 whitespace-nowrap">
                <Plus className="h-4 w-4" /> Request Commodity
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Request a New Commodity</DialogTitle>
                <DialogDescription>
                  Fill out the form below to request a new commodity for the platform.
                </DialogDescription>
              </DialogHeader>
              <form onSubmit={handleRequestSubmit} className="space-y-4">
                {/* Contact Information */}
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="request-name">Full Name *</Label>
                      <Input
                        id="request-name"
                        placeholder="Enter your full name"
                        value={requestFormData.name}
                        onChange={(e) => setRequestFormData(prev => ({ ...prev, name: e.target.value }))}
                        required
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="request-company">Company Name *</Label>
                      <Input
                        id="request-company"
                        placeholder="Enter your company name"
                        value={requestFormData.company}
                        onChange={(e) => setRequestFormData(prev => ({ ...prev, company: e.target.value }))}
                        required
                      />
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="request-email">Email *</Label>
                      <Input
                        id="request-email"
                        type="email"
                        placeholder="Enter your email"
                        value={requestFormData.email}
                        onChange={(e) => setRequestFormData(prev => ({ ...prev, email: e.target.value }))}
                        required
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="request-phone">Phone Number</Label>
                      <Input
                        id="request-phone"
                        type="tel"
                        placeholder="Enter your phone number"
                        value={requestFormData.phone}
                        onChange={(e) => setRequestFormData(prev => ({ ...prev, phone: e.target.value }))}
                      />
                    </div>
                  </div>
                </div>

                {/* Commodity Information */}
                <div className="space-y-2">
                  <Label htmlFor="commodity-name">Commodity Name *</Label>
                  <Input
                    id="commodity-name"
                    placeholder="Enter commodity name"
                    value={requestFormData.commodityName}
                    onChange={(e) => setRequestFormData(prev => ({ ...prev, commodityName: e.target.value }))}
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="market-code">Market Code *</Label>
                  <Input
                    id="market-code"
                    placeholder="e.g., ZW for Wheat"
                    value={requestFormData.marketCode}
                    onChange={(e) => setRequestFormData(prev => ({ ...prev, marketCode: e.target.value }))}
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="exchange">Exchange *</Label>
                  <Select
                    value={requestFormData.exchange}
                    onValueChange={(value) => setRequestFormData(prev => ({ ...prev, exchange: value }))}
                    required
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select an exchange" />
                    </SelectTrigger>
                    <SelectContent>
                      {exchanges.slice(1).map((exchange) => (
                        <SelectItem key={exchange.value} value={exchange.value}>
                          {exchange.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="details">Additional Details</Label>
                  <Textarea
                    id="details"
                    placeholder="Any specific requirements or information..."
                    value={requestFormData.details}
                    onChange={(e) => setRequestFormData(prev => ({ ...prev, details: e.target.value }))}
                    className="min-h-[100px]"
                  />
                </div>
                <Button type="submit" className="w-full">Submit Request</Button>
              </form>
            </DialogContent>
          </Dialog>
        </div>

        {/* Table */}
        <div className="rounded-lg border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Market Code</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Exchange</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Action</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredCommodities.map((commodity, index) => (
                <TableRow key={index}>
                  <TableCell className="font-medium">{commodity.name}</TableCell>
                  <TableCell>{commodity.marketCode}</TableCell>
                  <TableCell>{commodity.category}</TableCell>
                  <TableCell>{commodity.exchange}</TableCell>
                  <TableCell>
                    {commodity.status === "available" ? (
                      <span className="inline-flex items-center gap-1.5 rounded-full bg-teal-50 px-2 py-1 text-xs font-medium text-teal-700">
                        <span className="relative flex h-2 w-2">
                          <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-teal-400 opacity-75"></span>
                          <span className="relative inline-flex h-2 w-2 rounded-full bg-teal-500"></span>
                        </span>
                        Live
                      </span>
                    ) : (
                      <span className={cn(
                        "inline-flex items-center rounded-full px-2 py-1 text-xs font-medium",
                        commodity.status === "coming-soon" && "bg-amber-50 text-amber-700",
                        commodity.status === "in-queue" && "bg-gray-100 text-gray-700"
                      )}>
                        {commodity.status === "coming-soon" ? "Coming Soon" : "In Queue"}
                      </span>
                    )}
                  </TableCell>
                  <TableCell>
                    {commodity.status !== "available" && (
                      <Button
                        variant="outline"
                        size="sm"
                        className="gap-2"
                        onClick={() => {
                          setSelectedCommodity(commodity);
                          setShowNotifyForm(true);
                        }}
                      >
                        <Bell className="h-4 w-4" />
                        Notify Me
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </div>

      {/* Notify Me Dialog */}
      <Dialog open={showNotifyForm} onOpenChange={setShowNotifyForm}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Get Notified</DialogTitle>
            <DialogDescription>
              We'll notify you when {selectedCommodity?.name} becomes available for forecasting.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleNotifySubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="notify-name">Full Name *</Label>
              <Input
                id="notify-name"
                placeholder="Enter your full name"
                value={notifyFormData.name}
                onChange={(e) => setNotifyFormData(prev => ({ ...prev, name: e.target.value }))}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="notify-company">Company Name *</Label>
              <Input
                id="notify-company"
                placeholder="Enter your company name"
                value={notifyFormData.company}
                onChange={(e) => setNotifyFormData(prev => ({ ...prev, company: e.target.value }))}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="notify-email">Email *</Label>
              <Input
                id="notify-email"
                type="email"
                placeholder="Enter your email"
                value={notifyFormData.email}
                onChange={(e) => setNotifyFormData(prev => ({ ...prev, email: e.target.value }))}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="notify-phone">Phone Number (Optional)</Label>
              <Input
                id="notify-phone"
                type="tel"
                placeholder="Enter your phone number"
                value={notifyFormData.phone}
                onChange={(e) => setNotifyFormData(prev => ({ ...prev, phone: e.target.value }))}
              />
            </div>
            <Button type="submit" className="w-full">
              Set Notification
            </Button>
          </form>
        </DialogContent>
      </Dialog>
    </Card>
  );
}

export default CommodityTable;