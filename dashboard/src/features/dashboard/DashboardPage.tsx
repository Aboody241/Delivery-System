import { useQuery } from '@tanstack/react-query';
import api from '../../services/api';

interface StatsData {
  restaurants: number;
  products: number;
  orders: number;
  pending: number;
}

async function fetchStats(): Promise<StatsData> {
  const [restaurantsRes, productsRes, ordersRes] = await Promise.all([
    api.get('/restaurants?per_page=1'),
    api.get('/restaurants'),
    api.get('/orders?per_page=100'),
  ]);

  const restaurants = restaurantsRes.data?.meta?.total ?? restaurantsRes.data?.data?.length ?? 0;
  const products = productsRes.data?.data?.length ?? 0;
  const ordersData = ordersRes.data?.data ?? [];
  const orders = ordersRes.data?.meta?.total ?? ordersData.length;
  const pending = ordersData.filter(
    (o: { status: string }) => o.status === 'pending'
  ).length;

  return { restaurants, products, orders, pending };
}

const statCards = (data: StatsData) => [
  {
    color: 'orange',
    icon: '🏢',
    value: data.restaurants,
    label: 'Total Restaurants',
  },
  {
    color: 'blue',
    icon: '🍔',
    value: data.products,
    label: 'Total Products',
  },
  {
    color: 'green',
    icon: '📦',
    value: data.orders,
    label: 'Total Orders',
  },
  {
    color: 'red',
    icon: '⏳',
    value: data.pending,
    label: 'Pending Orders',
  },
];

export function DashboardPage() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: fetchStats,
    staleTime: 60_000,
  });

  return (
    <div>
      {/* Welcome Banner */}
      <div
        className="card"
        style={{
          background: 'linear-gradient(135deg, hsl(224, 20%, 16%) 0%, hsl(24, 30%, 14%) 100%)',
          border: '1px solid var(--border-primary)',
          marginBottom: 'var(--space-6)',
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        <div
          style={{
            position: 'absolute',
            top: '-40px',
            right: '-40px',
            width: '200px',
            height: '200px',
            background: 'radial-gradient(circle, hsla(24, 95%, 58%, 0.12) 0%, transparent 70%)',
            pointerEvents: 'none',
          }}
        />
        <div className="flex items-center justify-between">
          <div>
            <h2
              style={{
                fontFamily: 'var(--font-display)',
                fontSize: '22px',
                fontWeight: 700,
                color: 'var(--text-primary)',
                marginBottom: '6px',
              }}
            >
              Welcome back 👋
            </h2>
            <p style={{ color: 'var(--text-muted)', fontSize: '14px' }}>
              Here's what's happening on your delivery platform today.
            </p>
          </div>
          <div style={{ fontSize: '48px', opacity: 0.8 }}>🚚</div>
        </div>
      </div>

      {/* Stats Cards */}
      {isLoading ? (
        <div className="loading-state">
          <div className="spinner spinner-lg" />
          <span>Loading statistics…</span>
        </div>
      ) : isError ? (
        <div className="error-state">
          <span>⚠️</span>
          <span>Failed to load statistics. Make sure the API server is running.</span>
        </div>
      ) : data ? (
        <div className="grid-cols-4" style={{ marginBottom: 'var(--space-8)' }}>
          {statCards(data).map((card) => (
            <div key={card.label} className={`stat-card ${card.color}`}>
              <div className="stat-card-icon">{card.icon}</div>
              <div className="stat-card-value">{card.value.toLocaleString()}</div>
              <div className="stat-card-label">{card.label}</div>
            </div>
          ))}
        </div>
      ) : null}

      {/* Quick Access Cards */}
      <div className="grid-cols-2" style={{ gap: 'var(--space-4)' }}>
        <div className="card">
          <div className="card-header">
            <div>
              <div className="card-title">🚀 Quick Actions</div>
              <div className="card-subtitle">Common management tasks</div>
            </div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {[
              { label: 'Manage Restaurants', to: '/restaurants', icon: '🏢' },
              { label: 'Manage Products', to: '/products', icon: '🍔' },
              { label: 'View Orders', to: '/orders', icon: '📦' },
              { label: 'Manage Users', to: '/users', icon: '👥' },
            ].map((item) => (
              <a
                key={item.to}
                href={item.to}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '10px',
                  padding: '10px 14px',
                  background: 'var(--bg-elevated)',
                  border: '1px solid var(--border-subtle)',
                  borderRadius: 'var(--radius-md)',
                  textDecoration: 'none',
                  color: 'var(--text-secondary)',
                  fontSize: '14px',
                  fontWeight: 500,
                  transition: 'all var(--transition-base)',
                }}
                onMouseEnter={(e) => {
                  (e.currentTarget as HTMLElement).style.background = 'var(--bg-overlay)';
                  (e.currentTarget as HTMLElement).style.color = 'var(--text-primary)';
                }}
                onMouseLeave={(e) => {
                  (e.currentTarget as HTMLElement).style.background = 'var(--bg-elevated)';
                  (e.currentTarget as HTMLElement).style.color = 'var(--text-secondary)';
                }}
              >
                <span>{item.icon}</span>
                <span>{item.label}</span>
                <span style={{ marginLeft: 'auto', opacity: 0.4 }}>→</span>
              </a>
            ))}
          </div>
        </div>

        <div className="card">
          <div className="card-header">
            <div>
              <div className="card-title">📋 System Info</div>
              <div className="card-subtitle">Platform configuration</div>
            </div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {[
              { label: 'API Version', value: 'v1' },
              { label: 'Framework', value: 'Laravel 13' },
              { label: 'Frontend', value: 'React 19 + Vite' },
              { label: 'Auth Method', value: 'Laravel Sanctum' },
              { label: 'Database', value: 'SQLite (dev)' },
            ].map((item) => (
              <div
                key={item.label}
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  borderBottom: '1px solid var(--border-subtle)',
                  paddingBottom: '10px',
                }}
              >
                <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{item.label}</span>
                <span
                  style={{
                    fontSize: '13px',
                    fontWeight: 600,
                    color: 'var(--text-primary)',
                    fontFamily: 'var(--font-mono)',
                  }}
                >
                  {item.value}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
