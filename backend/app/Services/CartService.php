<?php

namespace App\Services;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Validation\ValidationException;

class CartService
{
    /**
     * Get or create a cart for the user.
     *
     * @param  int  $userId
     * @return \App\Models\Cart
     */
    public function getOrCreateCart(int $userId): Cart
    {
        return Cart::firstOrCreate(['user_id' => $userId]);
    }

    /**
     * Add an item to the cart.
     *
     * @param  \App\Models\Cart  $cart
     * @param  int  $productId
     * @param  int  $quantity
     * @return \App\Models\CartItem
     * @throws \Illuminate\Validation\ValidationException
     */
    public function addItem(Cart $cart, int $productId, int $quantity = 1): CartItem
    {
        $product = Product::findOrFail($productId);

        if (!$product->is_available) {
            throw ValidationException::withMessages([
                'product_id' => ['The selected product is currently unavailable.']
            ]);
        }

        // Lock cart to a single restaurant
        if ($cart->restaurant_id !== null && $cart->restaurant_id !== $product->restaurant_id) {
            throw ValidationException::withMessages([
                'product_id' => ['Your cart contains items from another restaurant. Please clear your cart first.']
            ]);
        }

        // If cart restaurant is not set, set it now
        if ($cart->restaurant_id === null) {
            $cart->update(['restaurant_id' => $product->restaurant_id]);
        }

        // Check if item is already in cart, then increment quantity
        $cartItem = CartItem::where('cart_id', $cart->id)
            ->where('product_id', $productId)
            ->first();

        if ($cartItem) {
            $cartItem->increment('quantity', $quantity);
            return $cartItem->fresh();
        }

        return CartItem::create([
            'cart_id' => $cart->id,
            'product_id' => $productId,
            'quantity' => $quantity,
        ]);
    }

    /**
     * Update the quantity of a cart item.
     *
     * @param  \App\Models\Cart  $cart
     * @param  int  $itemId
     * @param  int  $quantity
     * @return \App\Models\CartItem|null
     * @throws \Illuminate\Validation\ValidationException
     */
    public function updateItemQuantity(Cart $cart, int $itemId, int $quantity): ?CartItem
    {
        $cartItem = CartItem::where('cart_id', $cart->id)
            ->where('id', $itemId)
            ->first();

        if (!$cartItem) {
            throw ValidationException::withMessages([
                'item_id' => ['Cart item not found.']
            ]);
        }

        if ($quantity <= 0) {
            $this->removeItem($cart, $itemId);
            return null;
        }

        $cartItem->update(['quantity' => $quantity]);
        return $cartItem->fresh();
    }

    /**
     * Remove a single item from the cart.
     *
     * @param  \App\Models\Cart  $cart
     * @param  int  $itemId
     * @return void
     */
    public function removeItem(Cart $cart, int $itemId): void
    {
        CartItem::where('cart_id', $cart->id)
            ->where('id', $itemId)
            ->delete();

        // If no items remain, reset restaurant lock
        if ($cart->items()->count() === 0) {
            $cart->update(['restaurant_id' => null]);
        }
    }

    /**
     * Clear all items from the cart and reset the restaurant lock.
     *
     * @param  \App\Models\Cart  $cart
     * @return void
     */
    public function clearCart(Cart $cart): void
    {
        $cart->items()->delete();
        $cart->update(['restaurant_id' => null]);
    }
}
