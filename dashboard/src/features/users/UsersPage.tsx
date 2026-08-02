import { useState, type FormEvent } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../services/api';
import { useAuth } from '../../context/AuthContext';

// ─────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────
interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'owner' | 'customer' | 'driver';
  phone: string | null;
  address: string | null;
  created_at: string;
}

interface ApiValidationError {
  message?: string;
  errors?: Record<string, string[]>;
}

const roleOptions = [
  { value: 'admin', label: 'Admin' },
  { value: 'owner', label: 'Owner' },
  { value: 'customer', label: 'Customer' },
  { value: 'driver', label: 'Driver' },
];

// ─────────────────────────────────────────────
// API Call Functions
// ─────────────────────────────────────────────
async function fetchUsers(): Promise<User[]> {
  const response = await api.get('/users?per_page=100');
  return response.data.data;
}

export function UsersPage() {
  const queryClient = useQueryClient();
  const { user: currentUser } = useAuth();

  // Filters state
  const [searchQuery, setSearchQuery] = useState('');
  const [roleFilter, setRoleFilter] = useState('');

  // Modal Form state
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('customer');
  const [phone, setPhone] = useState('');
  const [address, setAddress] = useState('');
  const [validationErrors, setValidationErrors] = useState<Record<string, string[]>>({});
  const [submitError, setSubmitError] = useState('');

  // ─────────────────────────────────────────────
  // React Query Fetch Hook
  // ─────────────────────────────────────────────
  const { data: users = [], isLoading, isError } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  });

  // ─────────────────────────────────────────────
  // React Query Mutations
  // ─────────────────────────────────────────────

  // 1. Create User
  const createMutation = useMutation({
    mutationFn: async (payload: any) => {
      const response = await api.post('/users', payload);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      closeFormModal();
    },
    onError: (error: any) => {
      handleFormError(error);
    },
  });

  // 2. Update User
  const updateMutation = useMutation({
    mutationFn: async ({ id, payload }: { id: number; payload: any }) => {
      const response = await api.put(`/users/${id}`, payload);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      closeFormModal();
    },
    onError: (error: any) => {
      handleFormError(error);
    },
  });

  // 3. Delete User
  const deleteMutation = useMutation({
    mutationFn: async (id: number) => {
      const response = await api.delete(`/users/${id}`);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
    onError: (error: any) => {
      alert(error.response?.data?.message || 'Failed to delete user account');
    },
  });

  // ─────────────────────────────────────────────
  // Form Controls
  // ─────────────────────────────────────────────
  const openAddModal = () => {
    setSelectedUser(null);
    setName('');
    setEmail('');
    setPassword('');
    setRole('customer');
    setPhone('');
    setAddress('');
    setValidationErrors({});
    setSubmitError('');
    setIsFormOpen(true);
  };

  const openEditModal = (user: User) => {
    setSelectedUser(user);
    setName(user.name);
    setEmail(user.email);
    setPassword('');
    setRole(user.role);
    setPhone(user.phone || '');
    setAddress(user.address || '');
    setValidationErrors({});
    setSubmitError('');
    setIsFormOpen(true);
  };

  const closeFormModal = () => {
    setIsFormOpen(false);
    setSelectedUser(null);
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

    const payload: any = {
      name,
      email,
      role,
      phone: phone || null,
      address: address || null,
    };

    if (password) {
      payload.password = password;
    }

    if (selectedUser) {
      updateMutation.mutate({ id: selectedUser.id, payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const handleDelete = (id: number, name: string) => {
    if (currentUser?.id === id) {
      alert('You cannot delete your own logged-in account.');
      return;
    }

    if (window.confirm(`Are you sure you want to delete user "${name}"?`)) {
      deleteMutation.mutate(id);
    }
  };

  // ─────────────────────────────────────────────
  // Filter logic
  // ─────────────────────────────────────────────
  const filteredUsers = users.filter((u) => {
    const matchesSearch =
      u.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      u.email.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesRole = !roleFilter || u.role === roleFilter;
    return matchesSearch && matchesRole;
  });

  const getRoleBadgeClass = (r: string) => {
    switch (r) {
      case 'admin':
        return 'badge-red';
      case 'owner':
        return 'badge-orange';
      case 'driver':
        return 'badge-blue';
      default:
        return 'badge-gray';
    }
  };

  const isSubmitting = createMutation.isPending || updateMutation.isPending;

  return (
    <div>
      {/* Page Header */}
      <div className="page-header">
        <div>
          <h1 className="page-header-title">Users</h1>
          <p className="page-header-subtitle">Manage administrative, restaurant owner, driver and client accounts</p>
        </div>
        <button id="add-user-btn" className="btn btn-primary" onClick={openAddModal}>
          <span>+</span> Add User
        </button>
      </div>

      {/* Filters toolbar */}
      <div className="card" style={{ marginBottom: 'var(--space-6)', padding: 'var(--space-4) var(--space-6)' }}>
        <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap', alignItems: 'center' }}>
          {/* Search bar */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flex: 1, minWidth: '240px' }}>
            <span style={{ fontSize: '16px' }}>🔍</span>
            <input
              type="text"
              className="form-input"
              style={{ margin: 0 }}
              placeholder="Search by name or email address..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          {/* Role Filter */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <label htmlFor="role-filter" className="form-label" style={{ marginBottom: 0, whiteSpace: 'nowrap' }}>
              👤 Role:
            </label>
            <select
              id="role-filter"
              className="form-select"
              style={{ minWidth: '160px', margin: 0 }}
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value)}
            >
              <option value="">All Roles</option>
              {roleOptions.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
          </div>

          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Showing <b>{filteredUsers.length}</b> users
          </span>
        </div>
      </div>

      {/* States: Loading & Error */}
      {isLoading ? (
        <div className="loading-state">
          <div className="spinner spinner-lg" />
          <span>Fetching user registry…</span>
        </div>
      ) : isError ? (
        <div className="error-state">
          <span>⚠️</span>
          <span>Failed to load users. Verify that database is seeded and api serve is active.</span>
        </div>
      ) : filteredUsers.length === 0 ? (
        <div className="card">
          <div className="empty-state">
            <div className="empty-state-icon">👥</div>
            <h3>No Users Found</h3>
            <p>Try refining your search keyword or active role filter.</p>
          </div>
        </div>
      ) : (
        /* Users Table */
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <div className="table-wrapper">
            <table className="table">
              <thead>
                <tr>
                  <th>User ID</th>
                  <th>Full Name</th>
                  <th>Email Address</th>
                  <th>Role</th>
                  <th>Phone</th>
                  <th>Address</th>
                  <th style={{ width: '130px', textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((u) => (
                  <tr key={u.id}>
                    <td style={{ fontFamily: 'var(--font-mono)', color: 'var(--text-muted)' }}>#{u.id}</td>
                    <td style={{ fontWeight: 600, color: 'var(--text-primary)' }}>
                      {u.name} {currentUser?.id === u.id && <span style={{ opacity: 0.5, fontSize: '11px' }}>(You)</span>}
                    </td>
                    <td>{u.email}</td>
                    <td>
                      <span className={`badge ${getRoleBadgeClass(u.role)}`}>
                        {u.role}
                      </span>
                    </td>
                    <td>{u.phone || <span style={{ fontStyle: 'italic', opacity: 0.4 }}>—</span>}</td>
                    <td>
                      <div className="truncate" style={{ maxWidth: '240px' }} title={u.address || ''}>
                        {u.address || <span style={{ fontStyle: 'italic', opacity: 0.4 }}>—</span>}
                      </div>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        <button
                          className="btn btn-secondary btn-sm"
                          onClick={() => openEditModal(u)}
                        >
                          ✏️ Edit
                        </button>
                        <button
                          className="btn btn-danger btn-sm"
                          onClick={() => handleDelete(u.id, u.name)}
                          disabled={currentUser?.id === u.id || deleteMutation.isPending}
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
            <div className="modal-header">
              <h3 className="modal-title">
                {selectedUser ? `Edit Account: ${selectedUser.name}` : 'Create New User Account'}
              </h3>
              <button className="btn btn-ghost btn-sm" onClick={closeFormModal} style={{ padding: '4px 8px' }}>
                ✕
              </button>
            </div>

            <form onSubmit={handleSubmit}>
              <div className="modal-body" style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                {submitError && (
                  <div className="error-state" style={{ marginBottom: '16px' }}>
                    <span>⚠️</span>
                    <span>{submitError}</span>
                  </div>
                )}

                {/* Role select */}
                <div className="form-group">
                  <label className="form-label" htmlFor="user-role">Account Role</label>
                  <select
                    id="user-role"
                    className={`form-select ${validationErrors.role ? 'error' : ''}`}
                    value={role}
                    onChange={(e) => setRole(e.target.value)}
                    required
                  >
                    {roleOptions.map((opt) => (
                      <option key={opt.value} value={opt.value}>
                        {opt.label}
                      </option>
                    ))}
                  </select>
                  {validationErrors.role && (
                    <span className="form-error">⚠️ {validationErrors.role[0]}</span>
                  )}
                </div>

                {/* Name */}
                <div className="form-group">
                  <label className="form-label" htmlFor="user-name">Full Name</label>
                  <input
                    id="user-name"
                    type="text"
                    className={`form-input ${validationErrors.name ? 'error' : ''}`}
                    placeholder="e.g. Alice Smith"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    required
                  />
                  {validationErrors.name && (
                    <span className="form-error">⚠️ {validationErrors.name[0]}</span>
                  )}
                </div>

                {/* Email */}
                <div className="form-group">
                  <label className="form-label" htmlFor="user-email">Email Address</label>
                  <input
                    id="user-email"
                    type="email"
                    className={`form-input ${validationErrors.email ? 'error' : ''}`}
                    placeholder="e.g. alice@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                  {validationErrors.email && (
                    <span className="form-error">⚠️ {validationErrors.email[0]}</span>
                  )}
                </div>

                {/* Password */}
                <div className="form-group">
                  <label className="form-label" htmlFor="user-password">
                    Password {selectedUser && <span style={{ fontWeight: 400, opacity: 0.6 }}>(leave blank to keep current)</span>}
                  </label>
                  <input
                    id="user-password"
                    type="password"
                    className={`form-input ${validationErrors.password ? 'error' : ''}`}
                    placeholder="Minimum 6 characters"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required={!selectedUser}
                  />
                  {validationErrors.password && (
                    <span className="form-error">⚠️ {validationErrors.password[0]}</span>
                  )}
                </div>

                {/* Phone */}
                <div className="form-group">
                  <label className="form-label" htmlFor="user-phone">Phone Number</label>
                  <input
                    id="user-phone"
                    type="text"
                    className={`form-input ${validationErrors.phone ? 'error' : ''}`}
                    placeholder="e.g. +1 555-0144"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                  />
                  {validationErrors.phone && (
                    <span className="form-error">⚠️ {validationErrors.phone[0]}</span>
                  )}
                </div>

                {/* Address */}
                <div className="form-group">
                  <label className="form-label" htmlFor="user-address">Physical Address</label>
                  <input
                    id="user-address"
                    type="text"
                    className={`form-input ${validationErrors.address ? 'error' : ''}`}
                    placeholder="e.g. 789 Maple Ave, Brooklyn, NY"
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                  />
                  {validationErrors.address && (
                    <span className="form-error">⚠️ {validationErrors.address[0]}</span>
                  )}
                </div>
              </div>

              <div className="modal-footer">
                <button type="button" className="btn btn-secondary" onClick={closeFormModal} disabled={isSubmitting}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" disabled={isSubmitting} id="user-submit-btn">
                  {isSubmitting ? (
                    <>
                      <div className="spinner" />
                      Saving…
                    </>
                  ) : (
                    'Save Account'
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
