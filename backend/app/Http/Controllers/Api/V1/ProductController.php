<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\ProductRequest;
use App\Http\Resources\Api\V1\ProductResource;
use App\Services\ProductService;
use App\Services\RestaurantService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends ApiController
{
    protected ProductService $productService;
    protected RestaurantService $restaurantService;

    /**
     * ProductController constructor.
     *
     * @param  \App\Services\ProductService  $productService
     * @param  \App\Services\RestaurantService  $restaurantService
     */
    public function __construct(ProductService $productService, RestaurantService $restaurantService)
    {
        $this->productService = $productService;
        $this->restaurantService = $restaurantService;
    }

    /**
     * Display a listing of products for a restaurant.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $restaurantId
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request, int $restaurantId): JsonResponse
    {
        $restaurant = $this->restaurantService->getById($restaurantId);

        if (!$restaurant) {
            return $this->errorResponse('Restaurant not found', 404);
        }

        $filters = $request->only(['category_id', 'search', 'per_page']);

        // Check optionally authenticated user to show unavailable items
        $user = auth('sanctum')->user();
        if (!$user || !in_array($user->role, ['admin', 'owner'])) {
            $filters['only_available'] = true;
        }

        $products = $this->productService->getByRestaurant($restaurantId, $filters);

        return $this->successResponse(
            ProductResource::collection($products),
            'Products retrieved successfully'
        );
    }

    /**
     * Store a newly created product under a specific restaurant.
     *
     * @param  \App\Http\Requests\Api\V1\ProductRequest  $request
     * @param  int  $restaurantId
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(ProductRequest $request, int $restaurantId): JsonResponse
    {
        $restaurant = $this->restaurantService->getById($restaurantId);

        if (!$restaurant) {
            return $this->errorResponse('Restaurant not found', 404);
        }

        $product = $this->productService->create($restaurantId, $request->all());

        return $this->successResponse(
            new ProductResource($product),
            'Product created successfully',
            201
        );
    }

    /**
     * Display the specified product.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        $product = $this->productService->getById($id);

        if (!$product) {
            return $this->errorResponse('Product not found', 404);
        }

        return $this->successResponse(
            new ProductResource($product),
            'Product retrieved successfully'
        );
    }

    /**
     * Update the specified product.
     *
     * @param  \App\Http\Requests\Api\V1\ProductRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(ProductRequest $request, int $id): JsonResponse
    {
        $product = $this->productService->getById($id);

        if (!$product) {
            return $this->errorResponse('Product not found', 404);
        }

        $updated = $this->productService->update($product, $request->all());

        return $this->successResponse(
            new ProductResource($updated),
            'Product updated successfully'
        );
    }

    /**
     * Remove the specified product from storage.
     *
     * @param  \App\Http\Requests\Api\V1\ProductRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(ProductRequest $request, int $id): JsonResponse
    {
        $product = $this->productService->getById($id);

        if (!$product) {
            return $this->errorResponse('Product not found', 404);
        }

        $this->productService->delete($product);

        return $this->successResponse(null, 'Product deleted successfully');
    }
}
