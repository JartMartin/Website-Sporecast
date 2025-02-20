import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

interface ChartProps {
  data: Array<{
    month: string;
    value: number;
  }>;
  height?: number;
}

// Chart components with modern React patterns
function CustomXAxis({ dataKey = "month" }) {
  return (
    <XAxis 
      dataKey={dataKey}
      padding={{ left: 0, right: 0 }}
      tick={{ fill: '#666' }}
    />
  );
}

function CustomYAxis() {
  return (
    <YAxis
      padding={{ top: 20, bottom: 20 }}
      tick={{ fill: '#666' }}
    />
  );
}

function CustomLine({ dataKey = "value" }) {
  return (
    <Line 
      type="monotone"
      dataKey={dataKey}
      stroke="#0d9488"
      strokeWidth={2}
      dot={{ fill: '#0d9488' }}
    />
  );
}

export function Chart({ data, height = 300 }: ChartProps) {
  return (
    <div style={{ height }}>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart 
          data={data}
          margin={{ top: 10, right: 10, left: 0, bottom: 0 }}
        >
          <CartesianGrid strokeDasharray="3 3" stroke="#eee" />
          <CustomXAxis />
          <CustomYAxis />
          <Tooltip 
            contentStyle={{ 
              background: 'white',
              border: '1px solid #ccc',
              borderRadius: '4px'
            }}
          />
          <CustomLine />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}