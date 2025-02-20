import { Link } from "react-router-dom";
import { Loading3D } from "@/components/ui/loading-3d";
import { AlertCard } from "@/features/dashboard/alerts/components/alert-card";
import { EmptyAlerts } from "@/features/dashboard/alerts/components/empty-alerts";
import { useAlerts } from "@/hooks/use-alerts";
import { ChevronLeft } from "lucide-react";

export function AlertsPage() {
  const { alerts, loading, deleteAlert, toggleEmailNotifications } = useAlerts();

  // Show loading state while fetching alerts
  if (loading) {
    return (
      <div className="space-y-6">
        {/* Back Navigation */}
        <div className="flex items-center justify-between">
          <Link
            to="/dashboard"
            className="group flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            <ChevronLeft className="h-4 w-4 transition-transform group-hover:-translate-x-0.5" />
            Back to My Commodities
          </Link>
        </div>
        <div className="flex items-center justify-center min-h-[400px]">
          <Loading3D />
        </div>
      </div>
    );
  }

  // Show empty state when no alerts exist
  if (!alerts || alerts.length === 0) {
    return (
      <div className="space-y-6">
        {/* Back Navigation */}
        <div className="flex items-center justify-between">
          <Link
            to="/dashboard"
            className="group flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            <ChevronLeft className="h-4 w-4 transition-transform group-hover:-translate-x-0.5" />
            Back to My Commodities
          </Link>
        </div>
        <EmptyAlerts />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Back Navigation */}
      <div className="flex items-center justify-between">
        <Link
          to="/dashboard"
          className="group flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          <ChevronLeft className="h-4 w-4 transition-transform group-hover:-translate-x-0.5" />
          Back to My Commodities
        </Link>
      </div>

      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-neutral-900">Alerts</h1>
        <p className="mt-1 text-sm text-neutral-500">
          Stay informed about important market changes
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {alerts.map((alert) => (
          <AlertCard
            key={alert.id}
            commodityName={alert.commodity.name}
            type={alert.type}
            threshold={alert.threshold}
            isActive={alert.is_active}
            approachingTrigger={alert.approaching_trigger}
            progressToTrigger={alert.progress_to_trigger}
            emailNotifications={alert.email_notifications}
            onToggleEmailNotifications={(enabled) => toggleEmailNotifications(alert.id, enabled)}
            onDelete={() => deleteAlert(alert.id)}
          />
        ))}
      </div>
    </div>
  );
}

export default AlertsPage;