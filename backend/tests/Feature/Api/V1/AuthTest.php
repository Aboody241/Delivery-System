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
}
