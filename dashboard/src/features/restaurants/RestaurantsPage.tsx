import { useState, useRef, type FormEvent } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../services/api';

// ─────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────
interface Restaurant {
  id: number;
  name: string;
  description: string;
  address: string;
  phone: string;
  image_url: string | null;
  is_active: boolean | number;
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

export function RestaurantsPage() {
  const queryClient = useQueryClient();
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Component States
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [selectedRestaurant, setSelectedRestaurant] = useState<Restaurant | null>(null);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [address, setAddress] = useState('');
  const [phone, setPhone] = useState('');
  const [isActive, setIsActive] = useState(true);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [validationErrors, setValidationErrors] = useState<Record<string, string[]>>({});
  const [submitError, setSubmitError] = useState('');

  // ─────────────────────────────────────────────
  // React Query: Get Restaurants
  // ─────────────────────────────────────────────
  const { data: restaurants = [], isLoading, isError } = useQuery({
    queryKey: ['restaurants'],
    queryFn: fetchRestaurants,
  });

  // ─────────────────────────────────────────────
  // React Query Mutations
  // ─────────────────────────────────────────────
  
  // 1. Create Restaurant
  const createMutation = useMutation({
    mutationFn: async (formData: FormData) => {
      const response = await api.post('/restaurants', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['restaurants'] });
      closeFormModal();
    },
    onError: (error: any) => {
      handleFormError(error);
    },
  });

  // 2. Update Restaurant
  const updateMutation = useMutation({
    mutationFn: async ({ id, formData }: { id: number; formData: FormData }) => {
      // Laravel requires _method=PUT inside POST for multipart/form-data updates
      formData.append('_method', 'PUT');
      const response = await api.post(`/restaurants/${id}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['restaurants'] });
      closeFormModal();
    },
    onError: (error: any) => {
      handleFormError(error);
    },
  });

  // 3. Delete Restaurant
  const deleteMutation = useMutation({
    mutationFn: async (id: number) => {
      const response = await api.delete(`/restaurants/${id}`);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['restaurants'] });
    },
    onError: (error: any) => {
      alert(error.response?.data?.message || 'Failed to delete restaurant');
    },
  });

  // ─────────────────────────────────────────────
  // Form Control Handlers
  // ─────────────────────────────────────────────
  const openAddModal = () => {
    setSelectedRestaurant(null);
    setName('');
    setDescription('');
    setAddress('');
    setPhone('');
    setIsActive(true);
    setImageFile(null);
    setImagePreview(null);
    setValidationErrors({});
    setSubmitError('');
    setIsFormOpen(true);
  };

  const openEditModal = (restaurant: Restaurant) => {
    setSelectedRestaurant(restaurant);
    setName(restaurant.name);
    setDescription(restaurant.description);
    setAddress(restaurant.address);
    setPhone(restaurant.phone);
    setIsActive(Boolean(restaurant.is_active));
    setImageFile(null);
    setImagePreview(restaurant.image_url);
    setValidationErrors({});
    setSubmitError('');
    setIsFormOpen(true);
  };

  const closeFormModal = () => {
    setIsFormOpen(false);
    setSelectedRestaurant(null);
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
    formData.append('name', name);
    formData.append('description', description);
    formData.append('address', address);
    formData.append('phone', phone);
    formData.append('is_active', isActive ? '1' : '0');
    if (imageFile) {
      formData.append('image', imageFile);
    }

    if (selectedRestaurant) {
      updateMutation.mutate({ id: selectedRestaurant.id, formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const handleDelete = (id: number, name: string) => {
    if (window.confirm(`Are you sure you want to delete "${name}"? This will delete all its categories and products.`)) {
      deleteMutation.mutate(id);
    }
  };

  const isSubmitting = createMutation.isPending || updateMutation.isPending;

  return (
    <div>
      {/* Page Header */}
      <div className="page-header">
        <div>
          <h1 className="page-header-title">Restaurants</h1>
          <p className="page-header-subtitle">Manage all active and inactive restaurants</p>
        </div>
        <button id="add-restaurant-btn" className="btn btn-primary" onClick={openAddModal}>
          <span>+</span> Add Restaurant
        </button>
      </div>

      {/* States: Loading & Error */}
      {isLoading ? (
        <div className="loading-state">
          <div className="spinner spinner-lg" />
          <span>Loading restaurants catalog…</span>
        </div>
      ) : isError ? (
        <div className="error-state">
          <span>⚠️</span>
          <span>Failed to load restaurants. Please check if backend is serving requests.</span>
        </div>
      ) : restaurants.length === 0 ? (
        <div className="card">
          <div className="empty-state">
            <div className="empty-state-icon">🏢</div>
            <h3>No Restaurants Registered</h3>
            <p>Get started by registering your first delivery restaurant location.</p>
            <button className="btn btn-primary btn-sm mt-4" onClick={openAddModal}>
              + Add Restaurant
            </button>
          </div>
        </div>
      ) : (
        /* Restaurants Grid */
        <div className="grid-cols-3" style={{ gap: 'var(--space-6)' }}>
          {restaurants.map((restaurant) => (
            <div key={restaurant.id} className="card" style={{ display: 'flex', flexDirection: 'column', padding: 0, overflow: 'hidden' }}>
              {/* Card Image Header */}
              <div style={{ height: '180px', position: 'relative', background: 'var(--bg-elevated)' }}>
                {restaurant.image_url ? (
                  <img
                    src={restaurant.image_url}
                    alt={restaurant.name}
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                    onError={(e) => {
                      (e.currentTarget as HTMLImageElement).src = '';
                      (e.currentTarget as HTMLImageElement).style.display = 'none';
                    }}
                  />
                ) : (
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', fontSize: '48px' }}>
                    🏢
                  </div>
                )}
                {/* Active Status Badge */}
                <div style={{ position: 'absolute', top: '12px', right: '12px' }}>
                  <span className={`badge ${restaurant.is_active ? 'badge-green' : 'badge-red'}`}>
                    {restaurant.is_active ? 'Active' : 'Inactive'}
                  </span>
                </div>
              </div>

              {/* Card Body */}
              <div style={{ padding: 'var(--space-5)', flex: 1, display: 'flex', flexDirection: 'column' }}>
                <h3 className="card-title" style={{ fontSize: '18px', marginBottom: '8px' }}>{restaurant.name}</h3>
                <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '16px', flex: 1, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                  {restaurant.description || 'No description provided.'}
                </p>

                <div className="divider" style={{ margin: '12px 0' }} />

                <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', fontSize: '12px', color: 'var(--text-muted)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span>📞</span>
                    <span className="truncate">{restaurant.phone}</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span>📍</span>
                    <span className="truncate" title={restaurant.address}>{restaurant.address}</span>
                  </div>
                </div>

                <div className="divider" style={{ margin: '16px 0' }} />

                {/* Actions Footer */}
                <div style={{ display: 'flex', gap: '10px' }}>
                  <button
                    className="btn btn-secondary btn-sm"
                    style={{ flex: 1 }}
                    onClick={() => openEditModal(restaurant)}
                  >
                    ✏️ Edit
                  </button>
                  <button
                    className="btn btn-danger btn-sm"
                    style={{ padding: '0 12px' }}
                    onClick={() => handleDelete(restaurant.id, restaurant.name)}
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
                {selectedRestaurant ? `Edit Restaurant: ${selectedRestaurant.name}` : 'Add New Restaurant'}
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

                {/* Name */}
                <div className="form-group">
                  <label className="form-label" htmlFor="restaurant-name">Restaurant Name</label>
                  <input
                    id="restaurant-name"
                    type="text"
                    className={`form-input ${validationErrors.name ? 'error' : ''}`}
                    placeholder="e.g. Bella Italia"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    required
                  />
                  {validationErrors.name && (
                    <span className="form-error">⚠️ {validationErrors.name[0]}</span>
                  )}
                </div>

                {/* Phone */}
                <div className="form-group">
                  <label className="form-label" htmlFor="restaurant-phone">Phone Number</label>
                  <input
                    id="restaurant-phone"
                    type="text"
                    className={`form-input ${validationErrors.phone ? 'error' : ''}`}
                    placeholder="e.g. +1 555-0199"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    required
                  />
                  {validationErrors.phone && (
                    <span className="form-error">⚠️ {validationErrors.phone[0]}</span>
                  )}
                </div>

                {/* Address */}
                <div className="form-group">
                  <label className="form-label" htmlFor="restaurant-address">Address</label>
                  <input
                    id="restaurant-address"
                    type="text"
                    className={`form-input ${validationErrors.address ? 'error' : ''}`}
                    placeholder="e.g. 123 Main St, New York"
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    required
                  />
                  {validationErrors.address && (
                    <span className="form-error">⚠️ {validationErrors.address[0]}</span>
                  )}
                </div>

                {/* Description */}
                <div className="form-group">
                  <label className="form-label" htmlFor="restaurant-description">Description</label>
                  <textarea
                    id="restaurant-description"
                    className={`form-textarea ${validationErrors.description ? 'error' : ''}`}
                    placeholder="Brief description of cuisines and specialties..."
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    required
                  />
                  {validationErrors.description && (
                    <span className="form-error">⚠️ {validationErrors.description[0]}</span>
                  )}
                </div>

                {/* Image Upload Zone */}
                <div className="form-group">
                  <label className="form-label">Restaurant Cover Image</label>
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
                          style={{ maxHeight: '120px', borderRadius: 'var(--radius-sm)', objectFit: 'contain' }}
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

                {/* Status Toggle (Active / Inactive) */}
                <div className="form-group" style={{ flexDirection: 'row', alignItems: 'center', gap: '10px', marginTop: '12px' }}>
                  <input
                    id="restaurant-status-toggle"
                    type="checkbox"
                    checked={isActive}
                    onChange={(e) => setIsActive(e.target.checked)}
                    style={{ width: '18px', height: '18px', cursor: 'pointer', accentColor: 'var(--color-primary)' }}
                  />
                  <label htmlFor="restaurant-status-toggle" className="form-label" style={{ cursor: 'pointer', marginBottom: 0 }}>
                    Active (visible on customer app)
                  </label>
                </div>
              </div>

              {/* Modal Footer Actions */}
              <div className="modal-footer">
                <button type="button" className="btn btn-secondary" onClick={closeFormModal} disabled={isSubmitting}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" disabled={isSubmitting} id="restaurant-submit-btn">
                  {isSubmitting ? (
                    <>
                      <div className="spinner" />
                      Saving…
                    </>
                  ) : (
                    'Save Restaurant'
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
