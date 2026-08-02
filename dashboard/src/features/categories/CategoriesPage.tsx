import { useState, type FormEvent } from 'react';
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
  restaurant_id: number;
  name: string;
  description: string | null;
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

export function CategoriesPage() {
  const queryClient = useQueryClient();

  // Component States
  const [selectedRestaurantId, setSelectedRestaurantId] = useState('');
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(null);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [validationErrors, setValidationErrors] = useState<Record<string, string[]>>({});
  const [submitError, setSubmitError] = useState('');

  // ─────────────────────────────────────────────
  // React Query: Fetch Lists
  // ─────────────────────────────────────────────
  
  // 1. Fetch Restaurants Options
  const { data: restaurants = [] } = useQuery({
    queryKey: ['restaurants-options'],
    queryFn: fetchRestaurants,
  });

  // 2. Fetch Categories (enabled only when a restaurant is selected)
  const { data: categories = [], isLoading, isError } = useQuery({
    queryKey: ['categories', selectedRestaurantId],
    queryFn: () => fetchCategories(selectedRestaurantId),
    enabled: !!selectedRestaurantId,
  });

  // ─────────────────────────────────────────────
  // React Query Mutations
  // ─────────────────────────────────────────────
  
  // 1. Create Category
  const createMutation = useMutation({
    mutationFn: async (payload: { name: string; description: string }) => {
      const response = await api.post(`/restaurants/${selectedRestaurantId}/categories`, payload);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories', selectedRestaurantId] });
      closeFormModal();
    },
    onError: (error: any) => {
      handleFormError(error);
    },
  });

  // 2. Update Category
  const updateMutation = useMutation({
    mutationFn: async ({ id, payload }: { id: number; payload: { name: string; description: string } }) => {
      const response = await api.put(`/categories/${id}`, payload);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories', selectedRestaurantId] });
      closeFormModal();
    },
    onError: (error: any) => {
      handleFormError(error);
    },
  });

  // 3. Delete Category
  const deleteMutation = useMutation({
    mutationFn: async (id: number) => {
      const response = await api.delete(`/categories/${id}`);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories', selectedRestaurantId] });
    },
    onError: (error: any) => {
      alert(error.response?.data?.message || 'Failed to delete category');
    },
  });

  // ─────────────────────────────────────────────
  // Form Controls
  // ─────────────────────────────────────────────
  const openAddModal = () => {
    setSelectedCategory(null);
    setName('');
    setDescription('');
    setValidationErrors({});
    setSubmitError('');
    setIsFormOpen(true);
  };

  const openEditModal = (category: Category) => {
    setSelectedCategory(category);
    setName(category.name);
    setDescription(category.description || '');
    setValidationErrors({});
    setSubmitError('');
    setIsFormOpen(true);
  };

  const closeFormModal = () => {
    setIsFormOpen(false);
    setSelectedCategory(null);
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

    const payload = { name, description };

    if (selectedCategory) {
      updateMutation.mutate({ id: selectedCategory.id, payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const handleDelete = (id: number, catName: string) => {
    if (window.confirm(`Are you sure you want to delete category "${catName}"? This will unlink its products.`)) {
      deleteMutation.mutate(id);
    }
  };

  const isSubmitting = createMutation.isPending || updateMutation.isPending;

  return (
    <div>
      {/* Page Header */}
      <div className="page-header">
        <div>
          <h1 className="page-header-title">Categories</h1>
          <p className="page-header-subtitle">Manage menu categories for each restaurant</p>
        </div>
        {selectedRestaurantId && (
          <button id="add-category-btn" className="btn btn-primary" onClick={openAddModal}>
            <span>+</span> Add Category
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

      {/* Categories Table Rendering depending on selectedRestaurantId */}
      {!selectedRestaurantId ? (
        <div className="card">
          <div className="empty-state">
            <div className="empty-state-icon">🏢</div>
            <h3>No Restaurant Selected</h3>
            <p>Please select a restaurant location from the filter menu above to manage its food categories.</p>
          </div>
        </div>
      ) : isLoading ? (
        <div className="loading-state">
          <div className="spinner spinner-lg" />
          <span>Fetching menu categories…</span>
        </div>
      ) : isError ? (
        <div className="error-state">
          <span>⚠️</span>
          <span>Failed to load categories. Make sure the API server is online.</span>
        </div>
      ) : categories.length === 0 ? (
        <div className="card">
          <div className="empty-state">
            <div className="empty-state-icon">🏷️</div>
            <h3>No Categories Found</h3>
            <p>This restaurant has no food categories registered yet.</p>
            <button className="btn btn-primary btn-sm mt-4" onClick={openAddModal}>
              + Add First Category
            </button>
          </div>
        </div>
      ) : (
        /* Categories Table */
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <div className="table-wrapper">
            <table className="table">
              <thead>
                <tr>
                  <th>Category Name</th>
                  <th>Description</th>
                  <th style={{ width: '120px', textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {categories.map((category) => (
                  <tr key={category.id}>
                    <td style={{ fontWeight: 600, color: 'var(--text-primary)' }}>{category.name}</td>
                    <td style={{ color: 'var(--text-secondary)' }}>
                      {category.description || <span style={{ fontStyle: 'italic', opacity: 0.5 }}>No description</span>}
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        <button
                          className="btn btn-secondary btn-sm"
                          onClick={() => openEditModal(category)}
                        >
                          ✏️
                        </button>
                        <button
                          className="btn btn-danger btn-sm"
                          onClick={() => handleDelete(category.id, category.name)}
                          disabled={deleteMutation.isPending}
                        >
                          🗑️
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Form Modal (Add / Edit) */}
      {isFormOpen && (
        <div className="modal-overlay">
          <div className="modal">
            {/* Modal Header */}
            <div className="modal-header">
              <h3 className="modal-title">
                {selectedCategory ? `Edit Category: ${selectedCategory.name}` : 'Add New Category'}
              </h3>
              <button className="btn btn-ghost btn-sm" onClick={closeFormModal} style={{ padding: '4px 8px' }}>
                ✕
              </button>
            </div>

            {/* Modal Form Body */}
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                {submitError && (
                  <div className="error-state" style={{ marginBottom: '16px' }}>
                    <span>⚠️</span>
                    <span>{submitError}</span>
                  </div>
                )}

                {/* Name */}
                <div className="form-group">
                  <label className="form-label" htmlFor="category-name">Category Name</label>
                  <input
                    id="category-name"
                    type="text"
                    className={`form-input ${validationErrors.name ? 'error' : ''}`}
                    placeholder="e.g. Appetizers, Desserts"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    required
                  />
                  {validationErrors.name && (
                    <span className="form-error">⚠️ {validationErrors.name[0]}</span>
                  )}
                </div>

                {/* Description */}
                <div className="form-group">
                  <label className="form-label" htmlFor="category-description">Description</label>
                  <textarea
                    id="category-description"
                    className={`form-textarea ${validationErrors.description ? 'error' : ''}`}
                    placeholder="Brief details about items in this category..."
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                  />
                  {validationErrors.description && (
                    <span className="form-error">⚠️ {validationErrors.description[0]}</span>
                  )}
                </div>
              </div>

              {/* Modal Footer Actions */}
              <div className="modal-footer">
                <button type="button" className="btn btn-secondary" onClick={closeFormModal} disabled={isSubmitting}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" disabled={isSubmitting} id="category-submit-btn">
                  {isSubmitting ? (
                    <>
                      <div className="spinner" />
                      Saving…
                    </>
                  ) : (
                    'Save Category'
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
