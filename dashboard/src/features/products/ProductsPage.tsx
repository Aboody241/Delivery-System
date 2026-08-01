export function ProductsPage() {
  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-header-title">Products</h1>
          <p className="page-header-subtitle">Manage product catalog</p>
        </div>
        <button id="add-product-btn" className="btn btn-primary">
          <span>+</span> Add Product
        </button>
      </div>
      <div className="card">
        <div className="empty-state">
          <div className="empty-state-icon">🍔</div>
          <h3>Coming Soon</h3>
          <p>Products management page is being implemented.</p>
        </div>
      </div>
    </div>
  );
}
