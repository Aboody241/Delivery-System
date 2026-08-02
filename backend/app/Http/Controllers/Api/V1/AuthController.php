<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\ApiController;
use App\Http\Requests\Api\V1\LoginRequest;
use App\Http\Requests\Api\V1\RegisterRequest;
use App\Http\Resources\Api\V1\UserResource;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;

class AuthController extends ApiController
{
    protected AuthService $authService;

    /**
     * AuthController constructor.
     *
     * @param  \App\Services\AuthService  $authService
     */
    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Handle user registration request.
     *
     * @param  \App\Http\Requests\Api\V1\RegisterRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->authService->register($request->validated());

        return $this->successResponse([
            'user' => new UserResource($result['user']),
            'access_token' => $result['token'],
            'token_type' => 'Bearer',
        ], 'User registered successfully', 201);
    }

    /**
     * Handle user login request.
     *
     * @param  \App\Http\Requests\Api\V1\LoginRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login($request->validated());

        return $this->successResponse([
            'user' => new UserResource($result['user']),
            'access_token' => $result['token'],
            'token_type' => 'Bearer',
        ], 'User logged in successfully');
    }

    /**
     * Handle user logout request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(\Illuminate\Http\Request $request): JsonResponse
    {
        $this->authService->logout($request->user());

        return $this->successResponse(null, 'Logged out successfully');
    }

    /**
     * Get the authenticated user's profile.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function me(\Illuminate\Http\Request $request): JsonResponse
    {
        return $this->successResponse(
            new UserResource($request->user()),
            'Current user profile retrieved successfully'
        );
    }

    /**
     * Update the authenticated user's profile.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateProfile(\Illuminate\Http\Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
            'address' => ['nullable', 'string', 'max:1000'],
        ]);

        $user->update($validated);

        return $this->successResponse(
            new UserResource($user),
            'Profile updated successfully'
        );
    }
}
