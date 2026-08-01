<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\OrderRequest;
use App\Http\Resources\Api\V1\OrderResource;
use App\Services\OrderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends ApiController
{
    protected OrderService $orderService;

    /**
     * OrderController constructor.
     *
     * @param  \App\Services\OrderService  $orderService
     */
    public function __construct(OrderService $orderService)
    {
        $this->orderService = $orderService;
    }

    /**
     * Display a listing of orders (paginated).
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $perPage = $request->query('per_page', 15);
        $orders = $this->orderService->getOrders($request->user(), $perPage);

        return $this->successResponse(
            OrderResource::collection($orders),
            'Orders retrieved successfully'
        );
    }

    /**
     * Store a newly created order from the active cart.
     *
     * @param  \App\Http\Requests\Api\V1\OrderRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(OrderRequest $request): JsonResponse
    {
        $order = $this->orderService->createFromCart($request->user(), $request->validated());

        return $this->successResponse(
            new OrderResource($order),
            'Order placed successfully',
            201
        );
    }

    /**
     * Display the specified order details.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $order = $this->orderService->getById($id);

        if (!$order) {
            return $this->errorResponse('Order not found', 404);
        }

        // Authorize: Customers can only see their own orders
        $user = $request->user();
        if ($user->role === 'customer' && $order->user_id !== $user->id) {
            return $this->errorResponse('Unauthorized access to this order', 403);
        }

        return $this->successResponse(
            new OrderResource($order),
            'Order retrieved successfully'
        );
    }

    /**
     * Update the status of the specified order.
     *
     * @param  \App\Http\Requests\Api\V1\OrderRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateStatus(OrderRequest $request, int $id): JsonResponse
    {
        $order = $this->orderService->getById($id);

        if (!$order) {
            return $this->errorResponse('Order not found', 404);
        }

        $updated = $this->orderService->updateStatus($order, $request->validated()['status']);

        return $this->successResponse(
            new OrderResource($updated),
            'Order status updated successfully'
        );
    }
}
