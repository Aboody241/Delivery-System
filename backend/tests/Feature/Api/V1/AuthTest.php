<?php

namespace Tests\Feature\Api\V1;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test successful user registration.
     */
    public function test_user_can_register_successfully(): void
    {
        $payload = [
            'name' => 'Jane Doe',
            'email' => 'jane@example.com',
            'password' => 'password123',
            'role' => 'customer',
            'phone' => '1234567890',
            'address' => '123 Main St',
        ];

        $response = $this->postJson('/api/v1/register', $payload);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    'user' => [
                        'id',
                        'name',
                        'email',
                        'role',
                        'phone',
                        'address',
                        'created_at',
                    ],
                    'access_token',
                    'token_type',
                ]
            ])
            ->assertJson([
                'status' => 'success',
                'message' => 'User registered successfully',
                'data' => [
                    'user' => [
                        'name' => 'Jane Doe',
                        'email' => 'jane@example.com',
                        'role' => 'customer',
                        'phone' => '1234567890',
                        'address' => '123 Main St',
                    ],
                    'token_type' => 'Bearer',
                ]
            ]);

        $this->assertDatabaseHas('users', [
            'name' => 'Jane Doe',
            'email' => 'jane@example.com',
            'role' => 'customer',
        ]);
    }

    /**
     * Test registration validation errors.
     */
    public function test_user_registration_requires_mandatory_fields(): void
    {
        $response = $this->postJson('/api/v1/register', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name', 'email', 'password', 'role']);
    }

    /**
     * Test registration with duplicate email.
     */
    public function test_user_cannot_register_with_duplicate_email(): void
    {
        User::factory()->create([
            'email' => 'duplicate@example.com',
        ]);

        $payload = [
            'name' => 'Duplicate User',
            'email' => 'duplicate@example.com',
            'password' => 'password123',
            'role' => 'customer',
        ];

        $response = $this->postJson('/api/v1/register', $payload);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    /**
     * Test successful user login.
     */
    public function test_user_can_login_successfully(): void
    {
        $user = User::factory()->create([
            'email' => 'login@example.com',
            'password' => bcrypt('password123'),
        ]);

        $payload = [
            'email' => 'login@example.com',
            'password' => 'password123',
        ];

        $response = $this->postJson('/api/v1/login', $payload);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    'user' => [
                        'id',
                        'name',
                        'email',
                        'role',
                        'phone',
                        'address',
                        'created_at',
                    ],
                    'access_token',
                    'token_type',
                ]
            ])
            ->assertJson([
                'status' => 'success',
                'message' => 'User logged in successfully',
                'data' => [
                    'user' => [
                        'email' => 'login@example.com',
                    ],
                    'token_type' => 'Bearer',
                ]
            ]);
    }

    /**
     * Test login validation errors.
     */
    public function test_user_login_requires_mandatory_fields(): void
    {
        $response = $this->postJson('/api/v1/login', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email', 'password']);
    }

    /**
     * Test login with incorrect credentials.
     */
    public function test_user_cannot_login_with_incorrect_password(): void
    {
        User::factory()->create([
            'email' => 'wrongpass@example.com',
            'password' => bcrypt('correctpassword'),
        ]);

        $payload = [
            'email' => 'wrongpass@example.com',
            'password' => 'wrongpassword',
        ];

        $response = $this->postJson('/api/v1/login', $payload);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    /**
     * Test successful user logout.
     */
    public function test_user_can_logout_successfully(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $response = $this->postJson('/api/v1/logout', [], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Logged out successfully',
            ]);

        $this->assertCount(0, $user->tokens);
    }

    /**
     * Test logout when unauthenticated.
     */
    public function test_user_cannot_logout_when_unauthenticated(): void
    {
        $response = $this->postJson('/api/v1/logout', []);

        $response->assertStatus(401);
    }

    /**
     * Test successful fetching of current user profile.
     */
    public function test_user_can_fetch_profile_successfully(): void
    {
        $user = User::factory()->create([
            'name' => 'Profile User',
            'email' => 'profile@example.com',
            'role' => 'customer',
            'phone' => '111222333',
            'address' => '456 Second St',
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        $response = $this->getJson('/api/v1/me', [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Current user profile retrieved successfully',
                'data' => [
                    'id' => $user->id,
                    'name' => 'Profile User',
                    'email' => 'profile@example.com',
                    'role' => 'customer',
                    'phone' => '111222333',
                    'address' => '456 Second St',
                ]
            ]);
    }

    /**
     * Test fetching profile when unauthenticated.
     */
    public function test_user_cannot_fetch_profile_when_unauthenticated(): void
    {
        $response = $this->getJson('/api/v1/me');

        $response->assertStatus(401);
    }
}
