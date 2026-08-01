<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\RestaurantRequest;
use App\Http\Resources\Api\V1\RestaurantResource;
use App\Services\RestaurantService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RestaurantController extends ApiController
{
    protected RestaurantService $restaurantService;

    /**
     * RestaurantController constructor.
     *
     * @param  \App\Services\RestaurantService  $restaurantService
     */
    public function __construct(RestaurantService $restaurantService)
    {
        $this->restaurantService = $restaurantService;
    }

    /**
     * Display a listing of active restaurants.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        // Admin or owner can see all, customers/drivers see only active ones by default
        $user = auth('sanctum')->user();
        $onlyActive = true;
        if ($user && in_array($user->role, ['admin', 'owner'])) {
            $onlyActive = $request->query('only_active', '1') === '1';
        }

        $restaurants = $this->restaurantService->getAll($onlyActive);

        return $this->successResponse(
            RestaurantResource::collection($restaurants),
            'Restaurants retrieved successfully'
        );
    }

    /**
     * Store a newly created restaurant in storage.
     *
     * @param  \App\Http\Requests\Api\V1\RestaurantRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(RestaurantRequest $request): JsonResponse
    {
        $restaurant = $this->restaurantService->create($request->validated());

        return $this->successResponse(
            new RestaurantResource($restaurant),
            'Restaurant created successfully',
            201
        );
    }

    /**
     * Display the specified restaurant.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        $restaurant = $this->restaurantService->getById($id);

        if (!$restaurant) {
            return $this->errorResponse('Restaurant not found', 404);
        }

        return $this->successResponse(
            new RestaurantResource($restaurant),
            'Restaurant retrieved successfully'
        );
    }

    /**
     * Update the specified restaurant in storage.
     *
     * @param  \App\Http\Requests\Api\V1\RestaurantRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(RestaurantRequest $request, int $id): JsonResponse
    {
        $restaurant = $this->restaurantService->getById($id);

        if (!$restaurant) {
            return $this->errorResponse('Restaurant not found', 404);
        }

        $updated = $this->restaurantService->update($restaurant, $request->validated());

        return $this->successResponse(
            new RestaurantResource($updated),
            'Restaurant updated successfully'
        );
    }

    /**
     * Remove the specified restaurant from storage.
     *
     * @param  \App\Http\Requests\Api\V1\RestaurantRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(RestaurantRequest $request, int $id): JsonResponse
    {
        $restaurant = $this->restaurantService->getById($id);

        if (!$restaurant) {
            return $this->errorResponse('Restaurant not found', 404);
        }

        $this->restaurantService->delete($restaurant);

        return $this->successResponse(null, 'Restaurant deleted successfully');
    }
}
