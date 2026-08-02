<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\UserRequest;
use App\Http\Resources\Api\V1\UserResource;
use App\Services\UserService;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends ApiController
{
    protected UserService $userService;

    /**
     * UserController constructor.
     *
     * @param  \App\Services\UserService  $userService
     */
    public function __construct(UserService $userService)
    {
        $this->userService = $userService;
    }

    /**
     * Display a listing of users.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        // Double check authority
        if (!in_array($request->user()->role, ['admin', 'owner'])) {
            return $this->errorResponse('Unauthorized access.', 403);
        }

        $perPage = $request->query('per_page', 15);
        $users = $this->userService->getAll($perPage);

        return $this->successResponse(
            UserResource::collection($users),
            'Users retrieved successfully'
        );
    }

    /**
     * Store a newly created user in storage.
     *
     * @param  \App\Http\Requests\Api\V1\UserRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(UserRequest $request): JsonResponse
    {
        $user = $this->userService->create($request->validated());

        return $this->successResponse(
            new UserResource($user),
            'User created successfully',
            201
        );
    }

    /**
     * Update the specified user in storage.
     *
     * @param  \App\Http\Requests\Api\V1\UserRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(UserRequest $request, int $id): JsonResponse
    {
        $user = User::find($id);

        if (!$user) {
            return $this->errorResponse('User not found.', 404);
        }

        $updated = $this->userService->update($user, $request->validated());

        return $this->successResponse(
            new UserResource($updated),
            'User updated successfully'
        );
    }

    /**
     * Remove the specified user from storage.
     *
     * @param  \App\Http\Requests\Api\V1\UserRequest  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(UserRequest $request, int $id): JsonResponse
    {
        $user = User::find($id);

        if (!$user) {
            return $this->errorResponse('User not found.', 404);
        }

        // Prevent self deletion
        if ($request->user()->id === $user->id) {
            return $this->errorResponse('You cannot delete your own active account.', 422);
        }

        $this->userService->delete($user);

        return $this->successResponse(null, 'User deleted successfully');
    }
}
