export function CategoriesPage() {
  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-header-title">Categories</h1>
          <p className="page-header-subtitle">Manage food categories</p>
        </div>
        <button id="add-category-btn" className="btn btn-primary">
          <span>+</span> Add Category
        </button>
      </div>
      <div className="card">
        <div className="empty-state">
          <div className="empty-state-icon">🏷️</div>
          <h3>Coming Soon</h3>
          <p>Categories management page is being implemented.</p>
        </div>
      </div>
    </div>
  );
}
