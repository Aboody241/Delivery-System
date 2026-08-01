import { useLocation } from 'react-router-dom';

const pageTitles: Record<string, { title: string; subtitle: string }> = {
  '/': { title: 'Dashboard', subtitle: 'Overview of your delivery platform' },
  '/restaurants': { title: 'Restaurants', subtitle: 'Manage all restaurant listings' },
  '/categories': { title: 'Categories', subtitle: 'Manage food categories' },
  '/products': { title: 'Products', subtitle: 'Manage product catalog' },
  '/orders': { title: 'Orders', subtitle: 'Monitor and manage customer orders' },
  '/users': { title: 'Users', subtitle: 'Manage platform users' },
};

export function Header() {
  const { pathname } = useLocation();
  const page = pageTitles[pathname] ?? { title: 'Dashboard', subtitle: '' };

  const now = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  return (
    <header className="header">
      <div className="header-left">
        <div>
          <div className="header-title">{page.title}</div>
          {page.subtitle && (
            <div className="header-subtitle">{page.subtitle}</div>
          )}
        </div>
      </div>

      <div className="header-right">
        <div className="header-badge">
          <div className="status-dot" />
          <span>API Online</span>
        </div>
        <div className="header-badge">
          <span>📅</span>
          <span>{now}</span>
        </div>
      </div>
    </header>
  );
}
