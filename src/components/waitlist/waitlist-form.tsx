import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/lib/supabase";
import { Loader2 } from "lucide-react";

export function WaitlistForm() {
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    full_name: "",
    email: "",
    company: "",
    interested_commodities: "",
  });
  const { toast } = useToast();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { error } = await supabase
        .from('waitlist_entries')
        .insert([{
          full_name: formData.full_name.trim(),
          email: formData.email.toLowerCase().trim(),
          company: formData.company.trim() || null,
          interested_commodities: formData.interested_commodities.trim() || null,
          notify_launch: true
        }]);

      if (error) {
        if (error.code === '23505') {
          throw new Error('This email is already on the waitlist.');
        }
        throw error;
      }

      toast({
        title: "Success!",
        description: "You've been added to our waitlist. We'll notify you when we launch!",
      });

      // Reset form
      setFormData({
        full_name: "",
        email: "",
        company: "",
        interested_commodities: "",
      });
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-md w-full mx-auto">
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold mb-2">Join the Waitlist</h2>
        <p className="text-muted-foreground">
          Be the first to know when we launch and get early access to our platform.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="full_name">Full Name *</Label>
          <Input
            id="full_name"
            value={formData.full_name}
            onChange={(e) => setFormData(prev => ({ ...prev, full_name: e.target.value }))}
            required
            placeholder="Enter your full name"
            disabled={loading}
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="email">Email Address *</Label>
          <Input
            id="email"
            type="email"
            value={formData.email}
            onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
            required
            placeholder="Enter your email"
            disabled={loading}
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="company">Company Name</Label>
          <Input
            id="company"
            value={formData.company}
            onChange={(e) => setFormData(prev => ({ ...prev, company: e.target.value }))}
            placeholder="Enter your company name (optional)"
            disabled={loading}
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="interested_commodities">Interested Commodities</Label>
          <Textarea
            id="interested_commodities"
            value={formData.interested_commodities}
            onChange={(e) => setFormData(prev => ({ ...prev, interested_commodities: e.target.value }))}
            placeholder="Which commodities are you most interested in? (optional)"
            disabled={loading}
            className="resize-none"
            rows={3}
          />
        </div>

        <Button
          type="submit"
          className="w-full"
          disabled={loading}
        >
          {loading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Joining Waitlist...
            </>
          ) : (
            'Join Waitlist'
          )}
        </Button>

        <p className="text-xs text-center text-muted-foreground">
          By joining the waitlist, you agree to receive updates about our launch and new features.
        </p>
      </form>
    </div>
  );
}