import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const navItems = [
  { to: '/', icon: '📊', label: 'Dashboard', end: true },
  { to: '/restaurants', icon: '🏢', label: 'Restaurants' },
  { to: '/categories', icon: '🏷️', label: 'Categories' },
  { to: '/products', icon: '🍔', label: 'Products' },
  { to: '/orders', icon: '📦', label: 'Orders' },
  { to: '/users', icon: '👥', label: 'Users' },
];

export function Sidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  const initials = user?.name
    ? user.name.split(' ').map((n) => n[0]).slice(0, 2).join('').toUpperCase()
    : 'AD';

  return (
    <aside className="sidebar">
      {/* Logo */}
      <div className="sidebar-logo">
        <div className="sidebar-logo-icon">🚚</div>
        <div className="sidebar-logo-text">
          <span>DeliverDash</span>
          <span>Admin Panel</span>
        </div>
      </div>

      {/* Navigation */}
      <nav className="sidebar-nav">
        <div className="sidebar-section">
          <span className="sidebar-section-label">Main</span>
        </div>

        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.end}
            className={({ isActive }) =>
              `nav-item${isActive ? ' active' : ''}`
            }
          >
            <span className="nav-item-icon">{item.icon}</span>
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>

      {/* Footer / User block */}
      <div className="sidebar-footer">
        <div className="user-avatar-block" onClick={handleLogout} title="Click to logout">
          <div className="avatar">{initials}</div>
          <div className="user-info">
            <span>{user?.name ?? 'Admin'}</span>
            <span>{user?.role}</span>
          </div>
          <span style={{ marginLeft: 'auto', fontSize: '14px', opacity: 0.5 }}>↩</span>
        </div>
      </div>
    </aside>
  );
}
