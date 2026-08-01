<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\CategoryRequest;
use App\Http\Resources\Api\V1\CategoryResource;
use App\Services\CategoryService;
use App\Services\RestaurantService;
use Illuminate\Http\JsonResponse;

class CategoryController extends ApiController
{
    protected CategoryService $categoryService;
    protected RestaurantService $restaurantService;

    /**
     * CategoryController constructor.
     *
     * @param  \App\Services\CategoryService  $categoryService
     * @param  \App\Services\RestaurantService  $restaurantService
     */
    public function __construct(CategoryService $categoryService, RestaurantService $restaurantService)
    {
        $this->categoryService = $categoryService;
        $this->restaurantService = $restaurantService;
    }

    /**
     * Display a listing of categories for a specific restaurant.
     *
     * @param  int  $restaurantId
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(int $restaurantId): JsonResponse
    {
        $restaurant = $this->restaurantService->getById($restaurantId);

        if (!$restaurant) {
            return $this->errorResponse('Restaurant not found', 404);
        }

        $categories = $this->categoryService->getByRestaurant($restaurantId);

        return $this->successResponse(
            CategoryResource::collection($categories),
            'Categories retrieved successfully'
        );
    }

    /**
     * Store a newly created category under a specific restaurant.
     *
     * @param  \App\Http\Requests\Api\V1\CategoryRequest  $request
     * @param  int  $restaurantId
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(CategoryRequest $request, int $restaurantId): JsonResponse
    {
        $restaurant = $this->restaurantService->getById($restaurantId);

        if (!$restaurant) {
            return $this->errorResponse('Restaurant not found', 404);
        }

        $category = $this->categoryService->create($restaurantId, $request->validated());

        return $this->successResponse(
            new CategoryResource($category),
            'Category created successfully',
            201
        );
    }

    /**
     * Update the specified category.
     *
     * @param  \App\Http\Requests\Api\V1\CategoryRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(CategoryRequest $request, int $id): JsonResponse
    {
        $category = $this->categoryService->getById($id);

        if (!$category) {
            return $this->errorResponse('Category not found', 404);
        }

        $updated = $this->categoryService->update($category, $request->validated());

        return $this->successResponse(
            new CategoryResource($updated),
            'Category updated successfully'
        );
    }

    /**
     * Remove the specified category from storage.
     *
     * @param  \App\Http\Requests\Api\V1\CategoryRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(CategoryRequest $request, int $id): JsonResponse
    {
        $category = $this->categoryService->getById($id);

        if (!$category) {
            return $this->errorResponse('Category not found', 404);
        }

        $this->categoryService->delete($category);

        return $this->successResponse(null, 'Category deleted successfully');
    }
}
