<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\CartItemRequest;
use App\Http\Resources\Api\V1\CartResource;
use App\Services\CartService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends ApiController
{
    protected CartService $cartService;

    /**
     * CartController constructor.
     *
     * @param  \App\Services\CartService  $cartService
     */
    public function __construct(CartService $cartService)
    {
        $this->cartService = $cartService;
    }

    /**
     * Display the authenticated user's cart.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Request $request): JsonResponse
    {
        $cart = $this->cartService->getOrCreateCart($request->user()->id);

        // Load items and products
        $cart->load('items.product');

        return $this->successResponse(
            new CartResource($cart),
            'Cart retrieved successfully'
        );
    }

    /**
     * Add an item to the cart.
     *
     * @param  \App\Http\Requests\Api\V1\CartItemRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function addItem(CartItemRequest $request): JsonResponse
    {
        $cart = $this->cartService->getOrCreateCart($request->user()->id);

        $productId = $request->input('product_id');
        $quantity = $request->input('quantity', 1);

        $this->cartService->addItem($cart, $productId, $quantity);

        $cart->load('items.product');

        return $this->successResponse(
            new CartResource($cart),
            'Item added to cart successfully',
            201
        );
    }

    /**
     * Update the quantity of a specific cart item.
     *
     * @param  \App\Http\Requests\Api\V1\CartItemRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateItem(CartItemRequest $request, int $id): JsonResponse
    {
        $cart = $this->cartService->getOrCreateCart($request->user()->id);

        $quantity = $request->input('quantity');

        $this->cartService->updateItemQuantity($cart, $id, $quantity);

        $cart->load('items.product');

        return $this->successResponse(
            new CartResource($cart),
            'Cart item quantity updated successfully'
        );
    }

    /**
     * Remove a specific item from the cart.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function removeItem(Request $request, int $id): JsonResponse
    {
        $cart = $this->cartService->getOrCreateCart($request->user()->id);

        $this->cartService->removeItem($cart, $id);

        $cart->load('items.product');

        return $this->successResponse(
            new CartResource($cart),
            'Item removed from cart successfully'
        );
    }

    /**
     * Clear all items from the cart.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function clear(Request $request): JsonResponse
    {
        $cart = $this->cartService->getOrCreateCart($request->user()->id);

        $this->cartService->clearCart($cart);

        $cart->load('items.product');

        return $this->successResponse(
            new CartResource($cart),
            'Cart cleared successfully'
        );
    }
}
