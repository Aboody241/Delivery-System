export function RestaurantsPage() {
  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-header-title">Restaurants</h1>
          <p className="page-header-subtitle">Manage all restaurant listings</p>
        </div>
        <button id="add-restaurant-btn" className="btn btn-primary">
          <span>+</span> Add Restaurant
        </button>
      </div>
      <div className="card">
        <div className="empty-state">
          <div className="empty-state-icon">🏢</div>
          <h3>Coming Soon</h3>
          <p>Restaurants management page is being implemented.</p>
        </div>
      </div>
    </div>
  );
}
