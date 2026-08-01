<?php

namespace Tests\Feature\Api\V1;

use App\Models\Restaurant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RestaurantTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test public user can list active restaurants.
     */
    public function test_public_user_can_list_active_restaurants(): void
    {
        Restaurant::factory()->create(['name' => 'Active Restaurant', 'is_active' => true]);
        Restaurant::factory()->create(['name' => 'Inactive Restaurant', 'is_active' => false]);

        $response = $this->getJson('/api/v1/restaurants');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Active Restaurant');
    }

    /**
     * Test admin can view both active and inactive restaurants.
     */
    public function test_admin_can_view_all_restaurants_with_flag(): void
    {
        Restaurant::factory()->create(['name' => 'Active Restaurant', 'is_active' => true]);
        Restaurant::factory()->create(['name' => 'Inactive Restaurant', 'is_active' => false]);

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        // Query with only_active = 0
        $response = $this->getJson('/api/v1/restaurants?only_active=0', [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    /**
     * Test public user can view single restaurant.
     */
    public function test_public_user_can_view_single_restaurant(): void
    {
        $restaurant = Restaurant::factory()->create([
            'name' => 'Pizza Palace',
            'phone' => '111-222-3333',
            'address' => '123 Pizza Way',
        ]);

        $response = $this->getJson("/api/v1/restaurants/{$restaurant->id}");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'id' => $restaurant->id,
                    'name' => 'Pizza Palace',
                    'phone' => '111-222-3333',
                    'address' => '123 Pizza Way',
                ]
            ]);
    }

    /**
     * Test admin or owner can create restaurant.
     */
    public function test_admin_or_owner_can_create_restaurant(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $payload = [
            'name' => 'Burger Queen',
            'description' => 'Royal Burgers',
            'address' => '456 Royal Dr',
            'phone' => '444-555-6666',
            'image_url' => 'https://example.com/burger.jpg',
            'is_active' => true,
        ];

        $response = $this->postJson('/api/v1/restaurants', $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.name', 'Burger Queen');

        $this->assertDatabaseHas('restaurants', [
            'name' => 'Burger Queen',
            'phone' => '444-555-6666',
        ]);
    }

    /**
     * Test customer cannot create restaurant.
     */
    public function test_customer_cannot_create_restaurant(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $token = $customer->createToken('auth_token')->plainTextToken;

        $payload = [
            'name' => 'Burger Queen',
            'address' => '456 Royal Dr',
            'phone' => '444-555-6666',
        ];

        $response = $this->postJson('/api/v1/restaurants', $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(403); // Forbidden
    }

    /**
     * Test admin can update restaurant.
     */
    public function test_admin_can_update_restaurant(): void
    {
        $restaurant = Restaurant::factory()->create(['name' => 'Old Name']);

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $payload = [
            'name' => 'New Name',
        ];

        $response = $this->putJson("/api/v1/restaurants/{$restaurant->id}", $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.name', 'New Name');

        $this->assertDatabaseHas('restaurants', [
            'id' => $restaurant->id,
            'name' => 'New Name',
        ]);
    }

    /**
     * Test admin can delete restaurant.
     */
    public function test_admin_can_delete_restaurant(): void
    {
        $restaurant = Restaurant::factory()->create();

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $response = $this->deleteJson("/api/v1/restaurants/{$restaurant->id}", [], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseMissing('restaurants', [
            'id' => $restaurant->id,
        ]);
    }
}
