<?php

namespace Tests\Feature\Api\V1;

use App\Models\Category;
use App\Models\Restaurant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CategoryTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test public user can list categories of a specific restaurant.
     */
    public function test_public_user_can_list_restaurant_categories(): void
    {
        $restaurant1 = Restaurant::factory()->create();
        $restaurant2 = Restaurant::factory()->create();

        Category::factory()->create(['name' => 'Pizza', 'restaurant_id' => $restaurant1->id]);
        Category::factory()->create(['name' => 'Burger', 'restaurant_id' => $restaurant2->id]);

        $response = $this->getJson("/api/v1/restaurants/{$restaurant1->id}/categories");

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Pizza');
    }

    /**
     * Test admin can create a category.
     */
    public function test_admin_can_create_category(): void
    {
        $restaurant = Restaurant::factory()->create();

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $payload = [
            'name' => 'Appetizers',
            'description' => 'Great starters',
        ];

        $response = $this->postJson("/api/v1/restaurants/{$restaurant->id}/categories", $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.name', 'Appetizers');

        $this->assertDatabaseHas('categories', [
            'restaurant_id' => $restaurant->id,
            'name' => 'Appetizers',
        ]);
    }

    /**
     * Test customer cannot create a category.
     */
    public function test_customer_cannot_create_category(): void
    {
        $restaurant = Restaurant::factory()->create();

        $customer = User::factory()->create(['role' => 'customer']);
        $token = $customer->createToken('auth_token')->plainTextToken;

        $payload = [
            'name' => 'Desserts',
        ];

        $response = $this->postJson("/api/v1/restaurants/{$restaurant->id}/categories", $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(403);
    }

    /**
     * Test unique category constraint scoped by restaurant.
     */
    public function test_category_name_must_be_unique_within_same_restaurant(): void
    {
        $restaurant1 = Restaurant::factory()->create();
        $restaurant2 = Restaurant::factory()->create();

        // Create initial category for restaurant 1
        Category::factory()->create(['name' => 'Drinks', 'restaurant_id' => $restaurant1->id]);

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $payload = [
            'name' => 'Drinks',
        ];

        // 1. Try to create duplicate "Drinks" in restaurant 1 (Should fail validation)
        $response1 = $this->postJson("/api/v1/restaurants/{$restaurant1->id}/categories", $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);
        $response1->assertStatus(422)
            ->assertJsonValidationErrors(['name']);

        // 2. Try to create "Drinks" in restaurant 2 (Should succeed since scoped to restaurant 2)
        $response2 = $this->postJson("/api/v1/restaurants/{$restaurant2->id}/categories", $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);
        $response2->assertStatus(201);
        $this->assertDatabaseHas('categories', [
            'restaurant_id' => $restaurant2->id,
            'name' => 'Drinks',
        ]);
    }

    /**
     * Test admin can update category.
     */
    public function test_admin_can_update_category(): void
    {
        $category = Category::factory()->create(['name' => 'Old Name']);

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $payload = [
            'name' => 'New Name',
        ];

        $response = $this->putJson("/api/v1/categories/{$category->id}", $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.name', 'New Name');

        $this->assertDatabaseHas('categories', [
            'id' => $category->id,
            'name' => 'New Name',
        ]);
    }

    /**
     * Test admin can delete category.
     */
    public function test_admin_can_delete_category(): void
    {
        $category = Category::factory()->create();

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $response = $this->deleteJson("/api/v1/categories/{$category->id}", [], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseMissing('categories', [
            'id' => $category->id,
        ]);
    }
}
