<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Validation\ValidationException;

class OrderService
{
    protected CartService $cartService;

    /**
     * OrderService constructor.
     *
     * @param  \App\Services\CartService  $cartService
     */
    public function __construct(CartService $cartService)
    {
        $this->cartService = $cartService;
    }

    /**
     * Get paginated orders list.
     *
     * @param  \App\Models\User  $user
     * @param  int  $perPage
     * @return \Illuminate\Contracts\Pagination\LengthAwarePaginator
     */
    public function getOrders(User $user, int $perPage = 15): LengthAwarePaginator
    {
        $query = Order::query()->with('items.product');

        // Customer sees only their own orders
        if ($user->role === 'customer') {
            $query->where('user_id', $user->id);
        }

        return $query->latest()->paginate($perPage);
    }

    /**
     * Get a single order by ID.
     *
     * @param  int  $id
     * @return \App\Models\Order|null
     */
    public function getById(int $id): ?Order
    {
        return Order::with('items.product')->find($id);
    }

    /**
     * Create an order from the user's active cart.
     *
     * @param  \App\Models\User  $user
     * @param  array  $data
     * @return \App\Models\Order
     * @throws \Illuminate\Validation\ValidationException
     */
    public function createFromCart(User $user, array $data): Order
    {
        $cart = $this->cartService->getOrCreateCart($user->id);

        if ($cart->items()->count() === 0) {
            throw ValidationException::withMessages([
                'cart' => ['Cannot checkout an empty cart.']
            ]);
        }

        // Calculate total amount
        $totalAmount = $cart->items->sum(function ($item) {
            $price = $item->product ? (float) $item->product->price : 0.0;
            return $price * (int) $item->quantity;
        });

        // Create the Order
        $order = Order::create([
            'user_id' => $user->id,
            'restaurant_id' => $cart->restaurant_id,
            'status' => 'pending',
            'total_amount' => $totalAmount,
            'delivery_address' => $data['delivery_address'] ?? $user->address ?? 'Default Address',
            'notes' => $data['notes'] ?? null,
        ]);

        // Create the Order Items
        foreach ($cart->items as $cartItem) {
            $product = $cartItem->product;
            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => $cartItem->product_id,
                'product_name' => $product?->name ?? 'Deleted Product',
                'price' => $product ? (float) $product->price : 0.0,
                'quantity' => $cartItem->quantity,
            ]);
        }

        // Clear the cart
        $this->cartService->clearCart($cart);

        return $order->load('items.product');
    }

    /**
     * Update order status.
     *
     * @param  \App\Models\Order  $order
     * @param  string  $status
     * @return \App\Models\Order
     */
    public function updateStatus(Order $order, string $status): Order
    {
        $order->update(['status' => $status]);
        return $order->fresh()->load('items.product');
    }
}
