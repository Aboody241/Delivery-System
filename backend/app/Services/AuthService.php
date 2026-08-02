<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthService
{
    /**
     * Register a new user and generate a Sanctum API token.
     *
     * @param  array  $data
     * @return array{user: \App\Models\User, token: string}
     */
    public function register(array $data): array
    {
        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
            'role' => $data['role'] ?? 'customer',
            'phone' => $data['phone'] ?? null,
            'address' => $data['address'] ?? null,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    /**
     * Authenticate a user and generate a Sanctum API token.
     *
     * @param  array  $data
     * @return array{user: \App\Models\User, token: string}
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function login(array $data): array
    {
        $user = User::where('email', $data['email'])->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => [__('auth.failed')],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    /**
     * Revoke the current user's active API token.
     *
     * @param  mixed  $user
     * @return void
     */
    public function logout(mixed $user): void
    {
        $user->currentAccessToken()->delete();
    }
}
