import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../services/api';

// ─────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────
interface Restaurant {
  id: number;
  name: string;
}

interface OrderItem {
  id: number;
  product_name: string;
  price: number;
  quantity: number;
  subtotal: number;
}

interface Order {
  id: number;
  user_id: number;
  user_name: string | null;
  restaurant_id: number;
  restaurant_name: string;
  status: 'pending' | 'accepted' | 'preparing' | 'ready' | 'out_for_delivery' | 'delivered' | 'cancelled';
  total_amount: number;
  delivery_address: string;
  notes: string | null;
  items: OrderItem[];
  created_at: string;
}

const statusOptions = [
  { value: 'pending', label: 'Pending', badgeClass: 'badge-yellow' },
  { value: 'accepted', label: 'Accepted', badgeClass: 'badge-blue' },
  { value: 'preparing', label: 'Preparing', badgeClass: 'badge-blue' },
  { value: 'ready', label: 'Ready', badgeClass: 'badge-green' },
  { value: 'out_for_delivery', label: 'Out for Delivery', badgeClass: 'badge-orange' },
  { value: 'delivered', label: 'Delivered', badgeClass: 'badge-green' },
  { value: 'cancelled', label: 'Cancelled', badgeClass: 'badge-red' },
];

// ─────────────────────────────────────────────
// API Call Functions
// ─────────────────────────────────────────────
async function fetchRestaurants(): Promise<Restaurant[]> {
  const response = await api.get('/restaurants');
  return response.data.data;
}

async function fetchOrders(): Promise<Order[]> {
  const response = await api.get('/orders?per_page=100');
  return response.data.data;
}

export function OrdersPage() {
  const queryClient = useQueryClient();

  // Filters state
  const [selectedRestaurantId, setSelectedRestaurantId] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('');

  // Modal details state
  const [detailOrder, setDetailOrder] = useState<Order | null>(null);

  // ─────────────────────────────────────────────
  // React Query Fetch Hooks
  // ─────────────────────────────────────────────
  
  // 1. Fetch Restaurants Options
  const { data: restaurants = [] } = useQuery({
    queryKey: ['restaurants-options'],
    queryFn: fetchRestaurants,
  });

  // 2. Fetch Orders
  const { data: orders = [], isLoading, isError } = useQuery({
    queryKey: ['orders'],
    queryFn: fetchOrders,
  });

  // ─────────────────────────────────────────────
  // React Query Update Status Mutation
  // ─────────────────────────────────────────────
  const updateStatusMutation = useMutation({
    mutationFn: async ({ id, status }: { id: number; status: string }) => {
      const response = await api.put(`/orders/${id}/status`, { status });
      return response.data.data;
    },
    onSuccess: (updatedOrder: Order) => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      // Update details modal if it's currently open for this order
      if (detailOrder && detailOrder.id === updatedOrder.id) {
        setDetailOrder(updatedOrder);
      }
    },
    onError: (error: any) => {
      alert(error.response?.data?.message || 'Failed to update order status');
    },
  });

  const handleStatusChange = (id: number, status: string) => {
    updateStatusMutation.mutate({ id, status });
  };

  // ─────────────────────────────────────────────
  // Filter & Format logic
  // ─────────────────────────────────────────────
  const filteredOrders = orders.filter((order) => {
    const matchesRestaurant = !selectedRestaurantId || order.restaurant_id.toString() === selectedRestaurantId;
    const matchesStatus = !selectedStatus || order.status === selectedStatus;
    return matchesRestaurant && matchesStatus;
  });

  const formatDate = (isoString: string) => {
    return new Date(isoString).toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const getBadgeClass = (status: string) => {
    return statusOptions.find((opt) => opt.value === status)?.badgeClass || 'badge-gray';
  };

  const getStatusLabel = (status: string) => {
    return statusOptions.find((opt) => opt.value === status)?.label || status;
  };

  return (
    <div>
      {/* Page Header */}
      <div className="page-header">
        <div>
          <h1 className="page-header-title">Orders</h1>
          <p className="page-header-subtitle">Track and manage client orders fulfillment flow</p>
        </div>
      </div>

      {/* Filters Bar */}
      <div className="card" style={{ marginBottom: 'var(--space-6)', padding: 'var(--space-4) var(--space-6)' }}>
        <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap', alignItems: 'center' }}>
          {/* Restaurant Filter */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <label htmlFor="res-filter" className="form-label" style={{ marginBottom: 0, whiteSpace: 'nowrap' }}>
              🏢 Restaurant:
            </label>
            <select
              id="res-filter"
              className="form-select"
              style={{ minWidth: '200px', margin: 0 }}
              value={selectedRestaurantId}
              onChange={(e) => setSelectedRestaurantId(e.target.value)}
            >
              <option value="">All Restaurants</option>
              {restaurants.map((res) => (
                <option key={res.id} value={res.id}>
                  {res.name}
                </option>
              ))}
            </select>
          </div>

          {/* Status Filter */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <label htmlFor="status-filter" className="form-label" style={{ marginBottom: 0, whiteSpace: 'nowrap' }}>
              ⏳ Status:
            </label>
            <select
              id="status-filter"
              className="form-select"
              style={{ minWidth: '180px', margin: 0 }}
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
            >
              <option value="">All Statuses</option>
              {statusOptions.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
          </div>

          {/* Count summary */}
          <span style={{ marginLeft: 'auto', fontSize: '13px', color: 'var(--text-muted)' }}>
            Showing <b>{filteredOrders.length}</b> orders
          </span>
        </div>
      </div>

      {/* States: Loading & Error */}
      {isLoading ? (
        <div className="loading-state">
          <div className="spinner spinner-lg" />
          <span>Fetching platform orders…</span>
        </div>
      ) : isError ? (
        <div className="error-state">
          <span>⚠️</span>
          <span>Failed to load orders. Please make sure the Laravel Backend is serve-enabled.</span>
        </div>
      ) : filteredOrders.length === 0 ? (
        <div className="card">
          <div className="empty-state">
            <div className="empty-state-icon">📦</div>
            <h3>No Orders Found</h3>
            <p>No orders matched your selected restaurant or status filters.</p>
          </div>
        </div>
      ) : (
        /* Orders Table */
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <div className="table-wrapper">
            <table className="table">
              <thead>
                <tr>
                  <th>Order ID</th>
                  <th>Placed At</th>
                  <th>Customer</th>
                  <th>Restaurant</th>
                  <th style={{ textAlign: 'center' }}>Items</th>
                  <th>Total Amount</th>
                  <th>Status</th>
                  <th style={{ width: '220px', textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredOrders.map((order) => (
                  <tr key={order.id}>
                    <td style={{ fontWeight: 700, fontFamily: 'var(--font-mono)', color: 'var(--color-primary)' }}>
                      #{order.id}
                    </td>
                    <td style={{ color: 'var(--text-secondary)' }}>{formatDate(order.created_at)}</td>
                    <td style={{ fontWeight: 500 }}>{order.user_name || 'Guest Customer'}</td>
                    <td>{order.restaurant_name}</td>
                    <td style={{ textAlign: 'center', fontWeight: 600 }}>{order.items.length}</td>
                    <td style={{ fontWeight: 700, color: 'var(--text-primary)' }}>
                      ${order.total_amount.toFixed(2)}
                    </td>
                    <td>
                      <span className={`badge ${getBadgeClass(order.status)}`}>
                        {getStatusLabel(order.status)}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end', alignItems: 'center' }}>
                        <button
                          className="btn btn-secondary btn-sm"
                          onClick={() => setDetailOrder(order)}
                          title="View order items and delivery details"
                        >
                          🔍 View
                        </button>
                        
                        {/* Inline Status changer */}
                        <select
                          className="form-select btn-sm"
                          style={{ width: '130px', margin: 0, paddingRight: '24px', backgroundPosition: 'right 6px center' }}
                          value={order.status}
                          onChange={(e) => handleStatusChange(order.id, e.target.value)}
                          disabled={updateStatusMutation.isPending}
                        >
                          {statusOptions.map((opt) => (
                            <option key={opt.value} value={opt.value}>
                              {opt.label}
                            </option>
                          ))}
                        </select>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Order Details Modal */}
      {detailOrder && (
        <div className="modal-overlay">
          <div className="modal modal-lg">
            {/* Modal Header */}
            <div className="modal-header">
              <div>
                <h3 className="modal-title" style={{ fontSize: '18px' }}>
                  Order Details <span style={{ fontFamily: 'var(--font-mono)', color: 'var(--color-primary)' }}>#{detailOrder.id}</span>
                </h3>
                <p style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>
                  Placed on {formatDate(detailOrder.created_at)} at {detailOrder.restaurant_name}
                </p>
              </div>
              <button className="btn btn-ghost btn-sm" onClick={() => setDetailOrder(null)} style={{ padding: '4px 8px' }}>
                ✕
              </button>
            </div>

            {/* Modal Body */}
            <div className="modal-body" style={{ maxHeight: '70vh', overflowY: 'auto' }}>
              <div className="grid-cols-2" style={{ marginBottom: '20px', alignItems: 'start' }}>
                {/* Left side: Client & Delivery Info */}
                <div className="card" style={{ padding: '16px' }}>
                  <h4 style={{ fontSize: '14px', fontWeight: 600, marginBottom: '10px', color: 'var(--color-primary)' }}>
                    👤 Customer & Delivery Info
                  </h4>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '13px' }}>
                    <div>
                      <span style={{ color: 'var(--text-muted)' }}>Name: </span>
                      <b>{detailOrder.user_name || 'Guest Customer'}</b>
                    </div>
                    <div>
                      <span style={{ color: 'var(--text-muted)' }}>Address: </span>
                      <b>{detailOrder.delivery_address}</b>
                    </div>
                  </div>
                </div>

                {/* Right side: Notes */}
                <div className="card" style={{ padding: '16px' }}>
                  <h4 style={{ fontSize: '14px', fontWeight: 600, marginBottom: '10px', color: 'var(--color-primary)' }}>
                    📝 Customer Notes
                  </h4>
                  <p style={{ fontSize: '13px', color: 'var(--text-secondary)', fontStyle: detailOrder.notes ? 'normal' : 'italic' }}>
                    {detailOrder.notes || 'No special delivery instructions provided.'}
                  </p>
                </div>
              </div>

              {/* Items Breakdown Table */}
              <h4 style={{ fontSize: '14px', fontWeight: 600, marginBottom: '10px' }}>📦 Purchased Items</h4>
              <div className="table-wrapper" style={{ marginBottom: '20px' }}>
                <table className="table">
                  <thead>
                    <tr>
                      <th>Product Item Name</th>
                      <th style={{ textAlign: 'right' }}>Price</th>
                      <th style={{ textAlign: 'center' }}>Quantity</th>
                      <th style={{ textAlign: 'right' }}>Subtotal</th>
                    </tr>
                  </thead>
                  <tbody>
                    {detailOrder.items.map((item) => (
                      <tr key={item.id}>
                        <td style={{ fontWeight: 600 }}>{item.product_name}</td>
                        <td style={{ textAlign: 'right' }}>${item.price.toFixed(2)}</td>
                        <td style={{ textAlign: 'center', fontWeight: 600 }}>x{item.quantity}</td>
                        <td style={{ textAlign: 'right', fontWeight: 700, color: 'var(--text-primary)' }}>
                          ${item.subtotal.toFixed(2)}
                        </td>
                      </tr>
                    ))}
                    {/* Overall Summary Row */}
                    <tr style={{ background: 'var(--bg-elevated)' }}>
                      <td colSpan={3} style={{ fontWeight: 700, textAlign: 'right' }}>Total Order Cost:</td>
                      <td style={{ textAlign: 'right', fontWeight: 800, fontSize: '16px', color: 'var(--color-primary)' }}>
                        ${detailOrder.total_amount.toFixed(2)}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            {/* Modal Footer (Status toggle inline) */}
            <div className="modal-footer" style={{ justifyContent: 'space-between' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Update Order Status:</span>
                <select
                  className="form-select"
                  style={{ width: '180px', margin: 0 }}
                  value={detailOrder.status}
                  onChange={(e) => handleStatusChange(detailOrder.id, e.target.value)}
                  disabled={updateStatusMutation.isPending}
                >
                  {statusOptions.map((opt) => (
                    <option key={opt.value} value={opt.value}>
                      {opt.label}
                    </option>
                  ))}
                </select>
              </div>
              <button className="btn btn-secondary" onClick={() => setDetailOrder(null)}>
                Close Details
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
