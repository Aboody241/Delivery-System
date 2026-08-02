import { useState, useRef, type FormEvent } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../services/api';

// ─────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────
interface Restaurant {
  id: number;
  name: string;
}

interface Category {
  id: number;
  name: string;
}

interface Product {
  id: number;
  category_id: number;
  category_name?: string;
  name: string;
  description: string | null;
  price: number;
  image_url: string | null;
  is_available: boolean | number;
}

interface ApiValidationError {
  message?: string;
  errors?: Record<string, string[]>;
}

// ─────────────────────────────────────────────
// API Call Functions
// ─────────────────────────────────────────────
async function fetchRestaurants(): Promise<Restaurant[]> {
  const response = await api.get('/restaurants');
  return response.data.data;
}

async function fetchCategories(restaurantId: string): Promise<Category[]> {
  if (!restaurantId) return [];
  const response = await api.get(`/restaurants/${restaurantId}/categories`);
  return response.data.data;
}

async function fetchProducts(restaurantId: string): Promise<Product[]> {
  if (!restaurantId) return [];
  const response = await api.get(`/restaurants/${restaurantId}/products`);
  return response.data.data;
}

export function ProductsPage() {
  const queryClient = useQueryClient();
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Filter state
  const [selectedRestaurantId, setSelectedRestaurantId] = useState('');

  // Form states
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [categoryId, setCategoryId] = useState('');
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');
  const [isAvailable, setIsAvailable] = useState(true);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [validationErrors, setValidationErrors] = useState<Record<string, string[]>>({});
  const [submitError, setSubmitError] = useState('');

  // ─────────────────────────────────────────────
  // React Query Fetch Hooks
  // ─────────────────────────────────────────────
  
  // 1. Fetch Restaurants
  const { data: restaurants = [] } = useQuery({
    queryKey: ['restaurants-options'],
    queryFn: fetchRestaurants,
  });

  // 2. Fetch Categories (enabled only when a restaurant is selected)
  const { data: categories = [] } = useQuery({
    queryKey: ['categories-options', selectedRestaurantId],
    queryFn: () => fetchCategories(selectedRestaurantId),
    enabled: !!selectedRestaurantId,
  });

  // 3. Fetch Products (enabled only when a restaurant is selected)
  const { data: products = [], isLoading, isError } = useQuery({
    queryKey: ['products', selectedRestaurantId],
    queryFn: () => fetchProducts(selectedRestaurantId),
    enabled: !!selectedRestaurantId,
  });

  // ─────────────────────────────────────────────
  // React Query Mutations
  // ─────────────────────────────────────────────

  // 1. Create Product
  const createMutation = useMutation({
    mutationFn: async (formData: FormData) => {
      const response = await api.post(`/restaurants/${selectedRestaurantId}/products`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products', selectedRestaurantId] });
      closeFormModal();
    },
    onError: (error: any) => {
      handleFormError(error);
    },
  });

  // 2. Update Product
  const updateMutation = useMutation({
    mutationFn: async ({ id, formData }: { id: number; formData: FormData }) => {
      // Laravel PUT workaround for file uploads inside multipart request
      formData.append('_method', 'PUT');
      const response = await api.post(`/products/${id}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products', selectedRestaurantId] });
      closeFormModal();
    },
    onError: (error: any) => {
      handleFormError(error);
    },
  });

  // 3. Delete Product
  const deleteMutation = useMutation({
    mutationFn: async (id: number) => {
      const response = await api.delete(`/products/${id}`);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products', selectedRestaurantId] });
    },
    onError: (error: any) => {
      alert(error.response?.data?.message || 'Failed to delete product');
    },
  });

  // ─────────────────────────────────────────────
  // Form Control Handlers
  // ─────────────────────────────────────────────
  const openAddModal = () => {
    setSelectedProduct(null);
    setCategoryId(categories[0]?.id.toString() || '');
    setName('');
    setDescription('');
    setPrice('');
    setIsAvailable(true);
    setImageFile(null);
    setImagePreview(null);
    setValidationErrors({});
    setSubmitError('');
    setIsFormOpen(true);
  };

  const openEditModal = (product: Product) => {
    setSelectedProduct(product);
    setCategoryId(product.category_id.toString());
    setName(product.name);
    setDescription(product.description || '');
    setPrice(product.price.toString());
    setIsAvailable(Boolean(product.is_available));
    setImageFile(null);
    setImagePreview(product.image_url);
    setValidationErrors({});
    setSubmitError('');
    setIsFormOpen(true);
  };

  const closeFormModal = () => {
    setIsFormOpen(false);
    setSelectedProduct(null);
    setImageFile(null);
    setImagePreview(null);
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setImageFile(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleFormError = (error: any) => {
    const apiError = error.response?.data as ApiValidationError | undefined;
    if (apiError?.errors) {
      setValidationErrors(apiError.errors);
    } else {
      setSubmitError(apiError?.message || 'Something went wrong. Please check your connection.');
    }
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    setValidationErrors({});
    setSubmitError('');

    const formData = new FormData();
    formData.append('category_id', categoryId);
    formData.append('name', name);
    formData.append('description', description);
    formData.append('price', price);
    formData.append('is_available', isAvailable ? '1' : '0');
    if (imageFile) {
      formData.append('image', imageFile);
    }

    if (selectedProduct) {
      updateMutation.mutate({ id: selectedProduct.id, formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const handleDelete = (id: number, prodName: string) => {
    if (window.confirm(`Are you sure you want to delete product "${prodName}"?`)) {
      deleteMutation.mutate(id);
    }
  };

  const isSubmitting = createMutation.isPending || updateMutation.isPending;

  return (
    <div>
      {/* Page Header */}
      <div className="page-header">
        <div>
          <h1 className="page-header-title">Products</h1>
          <p className="page-header-subtitle">Manage menu catalog and items availability</p>
        </div>
        {selectedRestaurantId && categories.length > 0 && (
          <button id="add-product-btn" className="btn btn-primary" onClick={openAddModal}>
            <span>+</span> Add Product
          </button>
        )}
      </div>

      {/* Restaurant Selector Filter */}
      <div className="card" style={{ marginBottom: 'var(--space-6)', padding: 'var(--space-4) var(--space-6)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', flexWrap: 'wrap' }}>
          <label htmlFor="restaurant-filter" className="form-label" style={{ marginBottom: 0, whiteSpace: 'nowrap' }}>
            🏢 Select Restaurant:
          </label>
          <select
            id="restaurant-filter"
            className="form-select"
            style={{ maxWidth: '320px', margin: 0 }}
            value={selectedRestaurantId}
            onChange={(e) => setSelectedRestaurantId(e.target.value)}
          >
            <option value="">-- Choose a Restaurant --</option>
            {restaurants.map((res) => (
              <option key={res.id} value={res.id}>
                {res.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Products Grid Rendering depending on selectedRestaurantId */}
      {!selectedRestaurantId ? (
        <div className="card">
          <div className="empty-state">
            <div className="empty-state-icon">🏢</div>
            <h3>No Restaurant Selected</h3>
            <p>Please select a restaurant location from the filter menu above to manage its product items.</p>
          </div>
        </div>
      ) : isLoading ? (
        <div className="loading-state">
          <div className="spinner spinner-lg" />
          <span>Fetching product items…</span>
        </div>
      ) : isError ? (
        <div className="error-state">
          <span>⚠️</span>
          <span>Failed to load products. Make sure the API server is online.</span>
        </div>
      ) : categories.length === 0 ? (
        <div className="card">
          <div className="empty-state">
            <div className="empty-state-icon">🏷️</div>
            <h3>No Categories Found</h3>
            <p>You must add at least one category under the Categories page before adding products.</p>
          </div>
        </div>
      ) : products.length === 0 ? (
        <div className="card">
          <div className="empty-state">
            <div className="empty-state-icon">🍔</div>
            <h3>No Products Found</h3>
            <p>This restaurant has no products registered yet.</p>
            <button className="btn btn-primary btn-sm mt-4" onClick={openAddModal}>
              + Add First Product
            </button>
          </div>
        </div>
      ) : (
        /* Products Grid */
        <div className="grid-cols-3" style={{ gap: 'var(--space-6)' }}>
          {products.map((product) => (
            <div key={product.id} className="card" style={{ display: 'flex', flexDirection: 'column', padding: 0, overflow: 'hidden' }}>
              {/* Cover Image */}
              <div style={{ height: '160px', position: 'relative', background: 'var(--bg-elevated)' }}>
                {product.image_url ? (
                  <img
                    src={product.image_url}
                    alt={product.name}
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                    onError={(e) => {
                      (e.currentTarget as HTMLImageElement).src = '';
                      (e.currentTarget as HTMLImageElement).style.display = 'none';
                    }}
                  />
                ) : (
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', fontSize: '48px' }}>
                    🍔
                  </div>
                )}
                {/* Available Status Badge */}
                <div style={{ position: 'absolute', top: '12px', right: '12px' }}>
                  <span className={`badge ${product.is_available ? 'badge-green' : 'badge-red'}`}>
                    {product.is_available ? 'Available' : 'Unavailable'}
                  </span>
                </div>
              </div>

              {/* Body */}
              <div style={{ padding: 'var(--space-5)', flex: 1, display: 'flex', flexDirection: 'column' }}>
                {/* Category Badge */}
                <div style={{ marginBottom: '8px' }}>
                  <span className="badge badge-gray">{product.category_name || 'Category'}</span>
                </div>

                <h3 className="card-title" style={{ fontSize: '16px', marginBottom: '6px' }}>{product.name}</h3>
                
                <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '14px', flex: 1, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                  {product.description || 'No description provided.'}
                </p>

                <div className="divider" style={{ margin: '10px 0' }} />

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
                  <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Price</span>
                  <span style={{ fontSize: '18px', fontWeight: 700, color: 'var(--color-primary)' }}>
                    ${Number(product.price).toFixed(2)}
                  </span>
                </div>

                {/* Footer Buttons */}
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button
                    className="btn btn-secondary btn-sm"
                    style={{ flex: 1 }}
                    onClick={() => openEditModal(product)}
                  >
                    ✏️ Edit
                  </button>
                  <button
                    className="btn btn-danger btn-sm"
                    style={{ padding: '0 12px' }}
                    onClick={() => handleDelete(product.id, product.name)}
                    disabled={deleteMutation.isPending}
                  >
                    🗑️
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Form Modal (Add / Edit) */}
      {isFormOpen && (
        <div className="modal-overlay">
          <div className="modal">
            {/* Modal Header */}
            <div className="modal-header">
              <h3 className="modal-title">
                {selectedProduct ? `Edit Product: ${selectedProduct.name}` : 'Add New Product'}
              </h3>
              <button className="btn btn-ghost btn-sm" onClick={closeFormModal} style={{ padding: '4px 8px' }}>
                ✕
              </button>
            </div>

            {/* Modal Form Body */}
            <form onSubmit={handleSubmit}>
              <div className="modal-body" style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                {submitError && (
                  <div className="error-state" style={{ marginBottom: '16px' }}>
                    <span>⚠️</span>
                    <span>{submitError}</span>
                  </div>
                )}

                {/* Category Dropdown Selector */}
                <div className="form-group">
                  <label className="form-label" htmlFor="product-category">Menu Category</label>
                  <select
                    id="product-category"
                    className={`form-select ${validationErrors.category_id ? 'error' : ''}`}
                    value={categoryId}
                    onChange={(e) => setCategoryId(e.target.value)}
                    required
                  >
                    <option value="">-- Choose Category --</option>
                    {categories.map((cat) => (
                      <option key={cat.id} value={cat.id}>
                        {cat.name}
                      </option>
                    ))}
                  </select>
                  {validationErrors.category_id && (
                    <span className="form-error">⚠️ {validationErrors.category_id[0]}</span>
                  )}
                </div>

                {/* Name */}
                <div className="form-group">
                  <label className="form-label" htmlFor="product-name">Product Name</label>
                  <input
                    id="product-name"
                    type="text"
                    className={`form-input ${validationErrors.name ? 'error' : ''}`}
                    placeholder="e.g. Double Beef Burger"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    required
                  />
                  {validationErrors.name && (
                    <span className="form-error">⚠️ {validationErrors.name[0]}</span>
                  )}
                </div>

                {/* Price */}
                <div className="form-group">
                  <label className="form-label" htmlFor="product-price">Price ($)</label>
                  <input
                    id="product-price"
                    type="number"
                    step="0.01"
                    min="0"
                    className={`form-input ${validationErrors.price ? 'error' : ''}`}
                    placeholder="e.g. 9.99"
                    value={price}
                    onChange={(e) => setPrice(e.target.value)}
                    required
                  />
                  {validationErrors.price && (
                    <span className="form-error">⚠️ {validationErrors.price[0]}</span>
                  )}
                </div>

                {/* Description */}
                <div className="form-group">
                  <label className="form-label" htmlFor="product-description">Description</label>
                  <textarea
                    id="product-description"
                    className={`form-textarea ${validationErrors.description ? 'error' : ''}`}
                    placeholder="Describe ingredients, portion sizes, custom options..."
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                  />
                  {validationErrors.description && (
                    <span className="form-error">⚠️ {validationErrors.description[0]}</span>
                  )}
                </div>

                {/* Image Upload Zone */}
                <div className="form-group">
                  <label className="form-label">Food Cover Image</label>
                  <div
                    style={{
                      border: '2px dashed var(--border-default)',
                      borderRadius: 'var(--radius-md)',
                      padding: '16px',
                      textAlign: 'center',
                      background: 'var(--bg-elevated)',
                      cursor: 'pointer',
                      position: 'relative',
                    }}
                    onClick={() => fileInputRef.current?.click()}
                  >
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/*"
                      style={{ display: 'none' }}
                      onChange={handleImageChange}
                    />

                    {imagePreview ? (
                      <div style={{ position: 'relative', display: 'inline-block' }}>
                        <img
                          src={imagePreview}
                          alt="Preview"
                          style={{ maxHeight: '110px', borderRadius: 'var(--radius-sm)', objectFit: 'contain' }}
                        />
                        <p style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '6px' }}>
                          Click to change image
                        </p>
                      </div>
                    ) : (
                      <div>
                        <span style={{ fontSize: '32px', display: 'block', marginBottom: '8px' }}>📸</span>
                        <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: 500 }}>
                          Select files to upload
                        </span>
                        <span style={{ display: 'block', fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px' }}>
                          PNG, JPG or WEBP up to 2MB
                        </span>
                      </div>
                    )}
                  </div>
                  {validationErrors.image && (
                    <span className="form-error">⚠️ {validationErrors.image[0]}</span>
                  )}
                </div>

                {/* Availability Toggle */}
                <div className="form-group" style={{ flexDirection: 'row', alignItems: 'center', gap: '10px', marginTop: '12px' }}>
                  <input
                    id="product-availability-toggle"
                    type="checkbox"
                    checked={isAvailable}
                    onChange={(e) => setIsAvailable(e.target.checked)}
                    style={{ width: '18px', height: '18px', cursor: 'pointer', accentColor: 'var(--color-primary)' }}
                  />
                  <label htmlFor="product-availability-toggle" className="form-label" style={{ cursor: 'pointer', marginBottom: 0 }}>
                    Available (show on customer app)
                  </label>
                </div>
              </div>

              {/* Modal Footer Actions */}
              <div className="modal-footer">
                <button type="button" className="btn btn-secondary" onClick={closeFormModal} disabled={isSubmitting}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" disabled={isSubmitting} id="product-submit-btn">
                  {isSubmitting ? (
                    <>
                      <div className="spinner" />
                      Saving…
                    </>
                  ) : (
                    'Save Product'
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
