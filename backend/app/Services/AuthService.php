<?php

namespace App\Services;

use App\Models\User;

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
            'role' => $data['role'],
            'phone' => $data['phone'] ?? null,
            'address' => $data['address'] ?? null,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }
}
