<?php

namespace Tests\Feature\Api\V1;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserTest extends TestCase
{
    use RefreshDatabase;

    protected User $admin;
    protected User $customer;

    protected function setUp(): void
    {
        parent::setUp();

        // Admin User
        $this->admin = User::factory()->create([
            'role' => 'admin',
        ]);

        // Customer User
        $this->customer = User::factory()->create([
            'role' => 'customer',
        ]);
    }

    /**
     * Test guest cannot access users endpoints.
     */
    public function test_guest_cannot_access_user_endpoints(): void
    {
        $this->getJson('/api/v1/users')->assertStatus(401);
        $this->postJson('/api/v1/users', [])->assertStatus(401);
        $this->putJson('/api/v1/users/1', [])->assertStatus(401);
        $this->deleteJson('/api/v1/users/1')->assertStatus(401);
    }

    /**
     * Test customer role cannot access users endpoints.
     */
    public function test_customer_cannot_access_user_endpoints(): void
    {
        $this->actingAs($this->customer);

        $this->getJson('/api/v1/users')->assertStatus(403);
        
        $this->postJson('/api/v1/users', [
            'name' => 'New User',
            'email' => 'newuser@example.com',
            'password' => 'password',
            'role' => 'driver',
        ])->assertStatus(403);

        $this->putJson("/api/v1/users/{$this->admin->id}", [
            'name' => 'Updated Admin',
        ])->assertStatus(403);

        $this->deleteJson("/api/v1/users/{$this->admin->id}")->assertStatus(403);
    }

    /**
     * Test admin can fetch paginated user accounts list.
     */
    public function test_admin_can_fetch_users_list(): void
    {
        User::factory()->count(5)->create();

        $response = $this->actingAs($this->admin)
            ->getJson('/api/v1/users')
            ->assertStatus(200);

        $response->assertJsonStructure([
            'status',
            'message',
            'data' => [
                '*' => ['id', 'name', 'email', 'role', 'phone', 'address', 'created_at']
            ],
            'links',
            'meta'
        ]);

        // admin, customer + 5 seeded = 7 total users
        $this->assertEquals(7, $response->json('meta.total'));
    }

    /**
     * Test admin can create a new user.
     */
    public function test_admin_can_create_user(): void
    {
        $payload = [
            'name' => 'Driver User',
            'email' => 'driver@example.com',
            'password' => 'securepassword',
            'role' => 'driver',
            'phone' => '+15551234',
            'address' => 'Delivery Hub 1',
        ];

        $response = $this->actingAs($this->admin)
            ->postJson('/api/v1/users', $payload)
            ->assertStatus(201);

        $response->assertJsonPath('data.name', 'Driver User');
        $response->assertJsonPath('data.email', 'driver@example.com');
        $response->assertJsonPath('data.role', 'driver');

        $this->assertDatabaseHas('users', [
            'email' => 'driver@example.com',
            'role' => 'driver',
        ]);
    }

    /**
     * Test validation fails on duplicate email creation.
     */
    public function test_create_validation_fails_on_duplicate_email(): void
    {
        $payload = [
            'name' => 'Duplicate Email User',
            'email' => $this->customer->email, // existing email
            'password' => 'password',
            'role' => 'customer',
        ];

        $this->actingAs($this->admin)
            ->postJson('/api/v1/users', $payload)
            ->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    /**
     * Test admin can update an existing user.
     */
    public function test_admin_can_update_user(): void
    {
        $payload = [
            'name' => 'Updated Customer Name',
            'email' => 'updatedemail@example.com',
            'role' => 'owner',
        ];

        $response = $this->actingAs($this->admin)
            ->putJson("/api/v1/users/{$this->customer->id}", $payload)
            ->assertStatus(200);

        $response->assertJsonPath('data.name', 'Updated Customer Name');
        $response->assertJsonPath('data.email', 'updatedemail@example.com');
        $response->assertJsonPath('data.role', 'owner');

        $this->assertDatabaseHas('users', [
            'id' => $this->customer->id,
            'email' => 'updatedemail@example.com',
            'role' => 'owner',
        ]);
    }

    /**
     * Test admin cannot delete their own logged-in account.
     */
    public function test_admin_cannot_self_delete(): void
    {
        $this->actingAs($this->admin)
            ->deleteJson("/api/v1/users/{$this->admin->id}")
            ->assertStatus(422)
            ->assertJsonPath('message', 'You cannot delete your own active account.');

        $this->assertDatabaseHas('users', ['id' => $this->admin->id]);
    }

    /**
     * Test admin can delete other users.
     */
    public function test_admin_can_delete_user(): void
    {
        $this->actingAs($this->admin)
            ->deleteJson("/api/v1/users/{$this->customer->id}")
            ->assertStatus(200)
            ->assertJsonPath('message', 'User deleted successfully');

        $this->assertDatabaseMissing('users', ['id' => $this->customer->id]);
    }
}
