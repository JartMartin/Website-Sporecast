import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { SporecastLogo } from "@/components/sporecast-logo";
import { supabase } from "@/lib/supabase";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { LogOut } from "lucide-react";

const mockData = [
  { date: '2024-01', price: 210 },
  { date: '2024-02', price: 215 },
  { date: '2024-03', price: 225 },
  { date: '2024-04', price: 218 },
  { date: '2024-05', price: 230 }
];

// Custom chart components with default parameters
const CustomXAxis = ({ dataKey = "", ...props }) => (
  <XAxis 
    dataKey={dataKey}
    padding={{ left: 0, right: 0 }}
    tick={{ fill: '#666' }}
    {...props}
  />
);

const CustomYAxis = (props) => (
  <YAxis
    padding={{ top: 20, bottom: 20 }}
    tick={{ fill: '#666' }}
    {...props}
  />
);

const CustomLine = ({ dataKey = "", stroke = "#0d9488", ...props }) => (
  <Line 
    type="monotone"
    dataKey={dataKey}
    stroke={stroke}
    strokeWidth={2}
    dot={{ fill: stroke }}
    {...props}
  />
);

export function DashboardPage() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    checkUser();
  }, []);

  async function checkUser() {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        navigate('/auth');
        return;
      }
      setUser(user);
    } catch (error) {
      navigate('/auth');
    } finally {
      setLoading(false);
    }
  }

  async function handleSignOut() {
    await supabase.auth.signOut();
    navigate('/');
  }

  if (loading) {
    return <div className="flex items-center justify-center min-h-screen">Loading...</div>;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="border-b bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <SporecastLogo />
            <Button variant="ghost" onClick={handleSignOut} className="gap-2">
              <LogOut className="h-4 w-4" /> Sign Out
            </Button>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <Card className="p-6">
            <h3 className="font-medium text-gray-500">Commodities Monitored</h3>
            <p className="text-3xl font-bold mt-2">3</p>
          </Card>
          <Card className="p-6">
            <h3 className="font-medium text-gray-500">Forecast Accuracy</h3>
            <p className="text-3xl font-bold mt-2">87%</p>
          </Card>
          <Card className="p-6">
            <h3 className="font-medium text-gray-500">Active Predictions</h3>
            <p className="text-3xl font-bold mt-2">12</p>
          </Card>
        </div>

        <Card className="p-6">
          <h2 className="text-xl font-semibold mb-4">Wheat Price Forecast</h2>
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart 
                data={mockData}
                margin={{ top: 10, right: 10, left: 0, bottom: 0 }}
              >
                <CartesianGrid strokeDasharray="3 3" stroke="#eee" />
                <CustomXAxis dataKey="date" />
                <CustomYAxis />
                <Tooltip 
                  contentStyle={{ 
                    background: 'white',
                    border: '1px solid #ccc',
                    borderRadius: '4px'
                  }}
                />
                <CustomLine dataKey="price" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </Card>
      </main>
    </div>
  );
}