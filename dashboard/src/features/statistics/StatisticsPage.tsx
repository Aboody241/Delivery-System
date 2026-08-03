import { useQuery } from '@tanstack/react-query';
import api from '../../services/api';

interface OrderItem {
  id: number;
  product_name: string;
  price: number;
  quantity: number;
}

interface Order {
  id: number;
  user_name: string;
  restaurant_name: string;
  status: 'pending' | 'accepted' | 'preparing' | 'ready' | 'out_for_delivery' | 'delivered' | 'cancelled';
  total_amount: number;
  created_at: string;
  items: OrderItem[];
}

interface StatsResult {
  totalRevenue: number;
  activeOrdersCount: number;
  completedOrdersCount: number;
  cancelledOrdersCount: number;
  revenueByDay: { day: string; value: number }[];
  statusDistribution: { status: string; count: number; color: string }[];
  restaurantLeaderboard: { name: string; count: number; revenue: number }[];
}

async function fetchStatsData(): Promise<StatsResult> {
  const [ordersRes] = await Promise.all([
    api.get('/orders?per_page=200'),
  ]);

  const orders: Order[] = ordersRes.data?.data ?? [];

  // 1. Calculations
  let totalRevenue = 0;
  let activeOrdersCount = 0;
  let completedOrdersCount = 0;
  let cancelledOrdersCount = 0;

  const statusCounts: Record<string, number> = {
    pending: 0,
    accepted: 0,
    preparing: 0,
    ready: 0,
    out_for_delivery: 0,
    delivered: 0,
    cancelled: 0,
  };

  const restaurantStats: Record<string, { count: number; revenue: number }> = {};

  // Group revenue by date (last 7 days of order activity)
  const revenueMap: Record<string, number> = {};

  orders.forEach((order) => {
    const amount = Number(order.total_amount) || 0;
    const status = order.status.toLowerCase();

    statusCounts[status] = (statusCounts[status] || 0) + 1;

    if (status === 'delivered') {
      totalRevenue += amount;
      completedOrdersCount++;
    } else if (status === 'cancelled') {
      cancelledOrdersCount++;
    } else {
      activeOrdersCount++;
    }

    // Top Restaurants
    const rName = order.restaurant_name || 'Unknown Restaurant';
    if (!restaurantStats[rName]) {
      restaurantStats[rName] = { count: 0, revenue: 0 };
    }
    restaurantStats[rName].count++;
    if (status === 'delivered') {
      restaurantStats[rName].revenue += amount;
    }

    // Revenue by Day
    if (status === 'delivered' && order.created_at) {
      const date = new Date(order.created_at);
      const dayLabel = date.toLocaleDateString('en-US', { weekday: 'short' });
      revenueMap[dayLabel] = (revenueMap[dayLabel] || 0) + amount;
    }
  });

  const today = new Date();
  const sortedRevenueByDay: { day: string; value: number }[] = [];
  
  for (let i = 6; i >= 0; i--) {
    const d = new Date();
    d.setDate(today.getDate() - i);
    const dayLabel = d.toLocaleDateString('en-US', { weekday: 'short' });
    sortedRevenueByDay.push({
      day: dayLabel,
      value: Math.round(revenueMap[dayLabel] || 0),
    });
  }

  // Status Distribution
  const statusColors: Record<string, string> = {
    pending: '#F59E0B',
    accepted: '#3B82F6',
    preparing: '#8B5CF6',
    ready: '#10B981',
    out_for_delivery: '#EF4444',
    delivered: '#059669',
    cancelled: '#6B7280',
  };

  const statusDistribution = Object.keys(statusCounts).map((key) => ({
    status: key.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase()),
    count: statusCounts[key],
    color: statusColors[key] || '#9CA3AF',
  })).filter(item => item.count > 0);

  // Top Restaurants Stats
  const restaurantLeaderboard = Object.keys(restaurantStats).map((name) => ({
    name,
    count: restaurantStats[name].count,
    revenue: Math.round(restaurantStats[name].revenue),
  })).sort((a, b) => b.revenue - a.revenue).slice(0, 5);

  return {
    totalRevenue: Math.round(totalRevenue),
    activeOrdersCount,
    completedOrdersCount,
    cancelledOrdersCount,
    revenueByDay: sortedRevenueByDay,
    statusDistribution,
    restaurantLeaderboard,
  };
}

export function StatisticsPage() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ['statistics-data'],
    queryFn: fetchStatsData,
    staleTime: 30_000,
  });

  if (isLoading) {
    return (
      <div className="loading-state">
        <div className="spinner spinner-lg" />
        <span>Analyzing metrics & loading charts…</span>
      </div>
    );
  }

  if (isError || !data) {
    return (
      <div className="error-state">
        <span>⚠️</span>
        <span>Failed to load system statistics. Ensure the API server is reachable.</span>
      </div>
    );
  }

  // Chart Constants
  const chartHeight = 160;
  const chartWidth = 500;
  const padding = 30;

  // Find max value for scaling Revenue Line Chart
  const maxRevenueValue = Math.max(...data.revenueByDay.map(d => d.value), 100);
  const revenuePoints = data.revenueByDay.map((d, index) => {
    const x = padding + (index * (chartWidth - padding * 2)) / (data.revenueByDay.length - 1);
    const y = chartHeight - padding - (d.value * (chartHeight - padding * 2)) / maxRevenueValue;
    return { x, y, day: d.day, value: d.value };
  });

  const linePath = revenuePoints.map((p, i) => `${i === 0 ? 'M' : 'L'} ${p.x} ${p.y}`).join(' ');
  const areaPath = `${linePath} L ${revenuePoints[revenuePoints.length - 1].x} ${chartHeight - padding} L ${revenuePoints[0].x} ${chartHeight - padding} Z`;

  // Pie/Donut Chart calculation
  const totalOrders = data.statusDistribution.reduce((acc, curr) => acc + curr.count, 0);
  let accumulatedAngle = 0;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-6)' }}>
      {/* Header */}
      <div>
        <h1 style={{ fontFamily: 'var(--font-display)', fontSize: '28px', fontWeight: 800, color: 'var(--text-primary)' }}>
          📊 Business Statistics
        </h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
          Comprehensive view of sales metrics, restaurant performance, and order distributions.
        </p>
      </div>

      {/* Metric Cards Row */}
      <div className="grid-cols-4" style={{ gap: 'var(--space-4)' }}>
        <div className="stat-card green" style={{ padding: '20px' }}>
          <div className="stat-card-icon" style={{ fontSize: '24px' }}>💰</div>
          <div className="stat-card-value" style={{ fontSize: '28px', fontWeight: 800, margin: '8px 0 4px 0' }}>
            ${data.totalRevenue.toLocaleString()}
          </div>
          <div className="stat-card-label" style={{ textTransform: 'none', letterSpacing: 'normal' }}>
            Total Revenue
          </div>
        </div>

        <div className="stat-card blue" style={{ padding: '20px' }}>
          <div className="stat-card-icon" style={{ fontSize: '24px' }}>⚡</div>
          <div className="stat-card-value" style={{ fontSize: '28px', fontWeight: 800, margin: '8px 0 4px 0' }}>
            {data.activeOrdersCount}
          </div>
          <div className="stat-card-label" style={{ textTransform: 'none', letterSpacing: 'normal' }}>
            Active Orders
          </div>
        </div>

        <div className="stat-card orange" style={{ padding: '20px' }}>
          <div className="stat-card-icon" style={{ fontSize: '24px' }}>✅</div>
          <div className="stat-card-value" style={{ fontSize: '28px', fontWeight: 800, margin: '8px 0 4px 0' }}>
            {data.completedOrdersCount}
          </div>
          <div className="stat-card-label" style={{ textTransform: 'none', letterSpacing: 'normal' }}>
            Completed Orders
          </div>
        </div>

        <div className="stat-card red" style={{ padding: '20px' }}>
          <div className="stat-card-icon" style={{ fontSize: '24px' }}>❌</div>
          <div className="stat-card-value" style={{ fontSize: '28px', fontWeight: 800, margin: '8px 0 4px 0' }}>
            {data.cancelledOrdersCount}
          </div>
          <div className="stat-card-label" style={{ textTransform: 'none', letterSpacing: 'normal' }}>
            Cancelled Orders
          </div>
        </div>
      </div>

      {/* Main Charts Grid */}
      <div className="grid-cols-2" style={{ gap: 'var(--space-6)' }}>
        {/* Revenue Trend Line Chart */}
        <div className="card" style={{ padding: '24px' }}>
          <div className="card-header" style={{ marginBottom: '16px' }}>
            <div>
              <div className="card-title" style={{ fontSize: '16px', fontWeight: 700 }}>📈 Revenue Trend (Last 7 Days)</div>
              <div className="card-subtitle">Daily completed sales volume</div>
            </div>
          </div>

          <div style={{ position: 'relative', width: '100%', display: 'flex', justifyContent: 'center' }}>
            <svg viewBox={`0 0 ${chartWidth} ${chartHeight}`} width="100%" height={chartHeight}>
              <defs>
                <linearGradient id="chartGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#10B981" stopOpacity="0.3" />
                  <stop offset="100%" stopColor="#10B981" stopOpacity="0.0" />
                </linearGradient>
              </defs>

              {/* Grid Lines */}
              {[0, 0.25, 0.5, 0.75, 1].map((val, i) => {
                const y = padding + val * (chartHeight - padding * 2);
                const gridVal = Math.round(maxRevenueValue - val * maxRevenueValue);
                return (
                  <g key={i}>
                    <line
                      x1={padding}
                      y1={y}
                      x2={chartWidth - padding}
                      y2={y}
                      stroke="var(--border-subtle)"
                      strokeWidth="1"
                      strokeDasharray="4 4"
                    />
                    <text
                      x={padding - 5}
                      y={y + 4}
                      fill="var(--text-muted)"
                      fontSize="9"
                      textAnchor="end"
                    >
                      ${gridVal}
                    </text>
                  </g>
                );
              })}

              {/* Area path under the line */}
              <path d={areaPath} fill="url(#chartGradient)" />

              {/* Line path */}
              <path
                d={linePath}
                fill="none"
                stroke="#10B981"
                strokeWidth="3"
                strokeLinecap="round"
                strokeLinejoin="round"
              />

              {/* Circles on vertices & value labels */}
              {revenuePoints.map((p, i) => (
                <g key={i}>
                  <circle
                    cx={p.x}
                    cy={p.y}
                    r="5"
                    fill="var(--bg-card)"
                    stroke="#10B981"
                    strokeWidth="2.5"
                  />
                  {p.value > 0 && (
                    <text
                      x={p.x}
                      y={p.y - 10}
                      fill="var(--text-primary)"
                      fontSize="10"
                      fontWeight="600"
                      textAnchor="middle"
                    >
                      ${p.value}
                    </text>
                  )}
                  {/* Day labels along X axis */}
                  <text
                    x={p.x}
                    y={chartHeight - 8}
                    fill="var(--text-muted)"
                    fontSize="10"
                    fontWeight="500"
                    textAnchor="middle"
                  >
                    {p.day}
                  </text>
                </g>
              ))}
            </svg>
          </div>
        </div>

        {/* Order Status Donut Chart */}
        <div className="card" style={{ padding: '24px' }}>
          <div className="card-header" style={{ marginBottom: '16px' }}>
            <div>
              <div className="card-title" style={{ fontSize: '16px', fontWeight: 700 }}>🍕 Order Status Distribution</div>
              <div className="card-subtitle">Split of current and past orders</div>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '20px', justifyContent: 'space-around' }}>
            {/* SVG Pie Chart */}
            <div style={{ width: '130px', height: '130px' }}>
              <svg viewBox="0 0 42 42" width="100%" height="100%">
                <circle cx="21" cy="21" r="15.915" fill="none" stroke="var(--border-subtle)" strokeWidth="6.2" />
                {data.statusDistribution.map((item, i) => {
                  const percentage = (item.count / totalOrders) * 100;
                  const strokeDasharray = `${percentage} ${100 - percentage}`;
                  const strokeDashoffset = 100 - accumulatedAngle + 25; // 25 adds offset so it starts from top
                  accumulatedAngle += percentage;

                  return (
                    <circle
                      key={i}
                      cx="21"
                      cy="21"
                      r="15.915"
                      fill="none"
                      stroke={item.color}
                      strokeWidth="6"
                      strokeDasharray={strokeDasharray}
                      strokeDashoffset={strokeDashoffset}
                      style={{ transition: 'all 0.4s ease' }}
                    />
                  );
                })}
                <g fill="var(--text-primary)">
                  <text x="50%" y="47%" textAnchor="middle" fontSize="5" fontWeight="bold">
                    {totalOrders}
                  </text>
                  <text x="50%" y="60%" textAnchor="middle" fontSize="3" fill="var(--text-muted)">
                    Orders
                  </text>
                </g>
              </svg>
            </div>

            {/* Chart Legend */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', flex: 1, maxHeight: '140px', overflowY: 'auto' }}>
              {data.statusDistribution.map((item, i) => {
                const pct = Math.round((item.count / totalOrders) * 100);
                return (
                  <div key={i} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '13px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span style={{ width: '10px', height: '10px', borderRadius: '50%', backgroundColor: item.color, display: 'inline-block' }} />
                      <span style={{ color: 'var(--text-secondary)' }}>{item.status}</span>
                    </div>
                    <span style={{ fontWeight: 600, color: 'var(--text-primary)' }}>
                      {item.count} ({pct}%)
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      {/* Top Performing Restaurants */}
      <div className="card" style={{ padding: '24px' }}>
        <div className="card-header" style={{ marginBottom: '16px' }}>
          <div>
            <div className="card-title" style={{ fontSize: '16px', fontWeight: 700 }}>🏆 Top Performing Restaurants</div>
            <div className="card-subtitle">Ranked by revenue contribution</div>
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {data.restaurantLeaderboard.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '20px', color: 'var(--text-muted)', fontSize: '14px' }}>
              No sales recorded yet.
            </div>
          ) : (
            data.restaurantLeaderboard.map((rest, index) => {
              const maxLeaderboardRevenue = data.restaurantLeaderboard[0]?.revenue || 100;
              const barPercentage = Math.round((rest.revenue / maxLeaderboardRevenue) * 100);
              
              return (
                <div key={rest.name} style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <span
                        style={{
                          width: '24px',
                          height: '24px',
                          borderRadius: '50%',
                          backgroundColor: index === 0 ? '#F59E0B' : index === 1 ? '#D1D5DB' : index === 2 ? '#B45309' : 'var(--bg-elevated)',
                          color: index < 3 ? '#111827' : 'var(--text-secondary)',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: '12px',
                          fontWeight: 'bold',
                        }}
                      >
                        {index + 1}
                      </span>
                      <span style={{ fontWeight: 600, fontSize: '14px', color: 'var(--text-primary)' }}>{rest.name}</span>
                    </div>
                    <div style={{ display: 'flex', gap: '20px', fontSize: '14px' }}>
                      <span style={{ color: 'var(--text-muted)' }}>{rest.count} orders</span>
                      <span style={{ fontWeight: 700, color: 'var(--text-primary)' }}>${rest.revenue.toLocaleString()}</span>
                    </div>
                  </div>
                  
                  {/* Progress Bar */}
                  <div style={{ height: '8px', width: '100%', backgroundColor: 'var(--bg-elevated)', borderRadius: '4px', overflow: 'hidden' }}>
                    <div
                      style={{
                        height: '100%',
                        width: `${barPercentage}%`,
                        background: 'linear-gradient(90deg, #10B981 0%, #3B82F6 100%)',
                        borderRadius: '4px',
                        transition: 'width 0.6s cubic-bezier(0.4, 0, 0.2, 1)',
                      }}
                    />
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
}
