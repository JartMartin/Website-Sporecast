import { useState, useEffect } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { useProfile } from "@/hooks/use-profile";
import { useCommodities } from "@/hooks/use-commodities";
import { Loader2, User2, Building2, Mail, CreditCard, Bell, Lock, Shield } from "lucide-react";

const roles = [
  { value: "purchase_department", label: "Purchase Department" },
  { value: "head_of_purchase", label: "Head of Purchase" },
  { value: "board_management", label: "Board Management" },
] as const;

type Role = typeof roles[number]['value'];

export function ProfilePage() {
  const { profile, loading: profileLoading, updateProfile } = useProfile();
  const { userCommodities, loading: commoditiesLoading } = useCommodities();
  const [saving, setSaving] = useState(false);
  const [formData, setFormData] = useState({
    full_name: '',
    role: '',
    company: '',
  });
  const { toast } = useToast();

  useEffect(() => {
    if (profile) {
      setFormData({
        full_name: profile.full_name || '',
        role: profile.role || '',
        company: profile.company || '',
      });
    }
  }, [profile]);

  const handleUpdateProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);

    try {
      const { error } = await updateProfile({
        full_name: formData.full_name.trim(),
        role: formData.role as Role,
        company: formData.company.trim(),
      });

      if (error) throw new Error(error);

      toast({
        title: "Success",
        description: "Your profile has been updated successfully.",
      });
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setSaving(false);
    }
  };

  if (profileLoading || commoditiesLoading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 className="h-8 w-8 animate-spin text-teal-600" />
      </div>
    );
  }

  // Calculate billing information
  const activeCommodities = userCommodities.length;
  const monthlyTotal = activeCommodities * 99; // €99 per commodity
  const nextBillingDate = new Date();
  nextBillingDate.setMonth(nextBillingDate.getMonth() + 1);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold mb-2">Profile Settings</h1>
        <p className="text-muted-foreground">Manage your account preferences and subscription</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Profile Settings */}
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <form onSubmit={handleUpdateProfile} className="p-6 space-y-6">
              <div className="flex items-center gap-4 pb-2">
                <div className="h-10 w-10 rounded-full bg-teal-50 flex items-center justify-center">
                  <User2 className="h-5 w-5 text-teal-600" />
                </div>
                <div>
                  <h3 className="font-semibold">Personal Information</h3>
                  <p className="text-sm text-muted-foreground">Update your personal details</p>
                </div>
              </div>

              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="email">Email</Label>
                    <div className="relative">
                      <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        id="email"
                        type="email"
                        value={profile?.email || ''}
                        readOnly
                        className="bg-gray-50 pl-9"
                      />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="fullName">Full Name</Label>
                    <div className="relative">
                      <User2 className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        id="fullName"
                        value={formData.full_name}
                        onChange={(e) => setFormData(prev => ({ ...prev, full_name: e.target.value }))}
                        disabled={saving}
                        className="pl-9"
                        required
                      />
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="role">Role</Label>
                    <Select
                      value={formData.role}
                      onValueChange={(value) => setFormData(prev => ({ ...prev, role: value }))}
                      disabled={saving}
                      required
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select your role" />
                      </SelectTrigger>
                      <SelectContent>
                        {roles.map((role) => (
                          <SelectItem key={role.value} value={role.value}>
                            {role.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="company">Company</Label>
                    <div className="relative">
                      <Building2 className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        id="company"
                        value={formData.company}
                        onChange={(e) => setFormData(prev => ({ ...prev, company: e.target.value }))}
                        disabled={saving}
                        className="pl-9"
                        required
                      />
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end">
                <Button
                  type="submit"
                  disabled={saving}
                  className="min-w-[120px]"
                >
                  {saving ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Saving...
                    </>
                  ) : (
                    'Save Changes'
                  )}
                </Button>
              </div>
            </form>
          </Card>

          {/* Billing Information */}
          <Card>
            <div className="p-6 space-y-6">
              <div className="flex items-center gap-4 pb-2">
                <div className="h-10 w-10 rounded-full bg-teal-50 flex items-center justify-center">
                  <CreditCard className="h-5 w-5 text-teal-600" />
                </div>
                <div>
                  <h3 className="font-semibold">Billing Information</h3>
                  <p className="text-sm text-muted-foreground">Manage your subscription and billing</p>
                </div>
              </div>

              <div className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="p-4 rounded-lg bg-neutral-50">
                    <div className="text-sm text-neutral-600">Active Commodities</div>
                    <div className="text-2xl font-semibold mt-1">{activeCommodities}</div>
                  </div>
                  <div className="p-4 rounded-lg bg-neutral-50">
                    <div className="text-sm text-neutral-600">Monthly Total</div>
                    <div className="text-2xl font-semibold mt-1">€{monthlyTotal}</div>
                  </div>
                </div>

                <div className="rounded-lg border p-4">
                  <div className="text-sm font-medium">Next Billing Date</div>
                  <div className="text-sm text-neutral-600 mt-1">
                    {nextBillingDate.toLocaleDateString('en-US', { 
                      year: 'numeric', 
                      month: 'long', 
                      day: 'numeric' 
                    })}
                  </div>
                </div>

                <div className="text-sm text-neutral-600">
                  Your subscription is billed monthly at €99 per commodity. Changes to your portfolio will be reflected in your next billing cycle.
                </div>
              </div>
            </div>
          </Card>
        </div>

        {/* Side Settings */}
        <div className="space-y-6">
          {/* Notification Preferences */}
          <Card>
            <div className="p-6 space-y-4">
              <div className="flex items-center gap-4">
                <div className="h-10 w-10 rounded-full bg-teal-50 flex items-center justify-center">
                  <Bell className="h-5 w-5 text-teal-600" />
                </div>
                <div>
                  <h3 className="font-semibold">Notifications</h3>
                  <p className="text-sm text-muted-foreground">Manage your alerts</p>
                </div>
              </div>
              <Button variant="outline" className="w-full">
                Configure Notifications
              </Button>
            </div>
          </Card>

          {/* Security Settings */}
          <Card>
            <div className="p-6 space-y-4">
              <div className="flex items-center gap-4">
                <div className="h-10 w-10 rounded-full bg-teal-50 flex items-center justify-center">
                  <Shield className="h-5 w-5 text-teal-600" />
                </div>
                <div>
                  <h3 className="font-semibold">Security</h3>
                  <p className="text-sm text-muted-foreground">Manage your security</p>
                </div>
              </div>
              <div className="space-y-2">
                <Button variant="outline" className="w-full gap-2">
                  <Lock className="h-4 w-4" />
                  Change Password
                </Button>
              </div>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}

export default ProfilePage;