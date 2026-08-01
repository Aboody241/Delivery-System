<?php

namespace Tests\Feature\Api\V1;

use App\Models\Category;
use App\Models\Product;
use App\Models\Restaurant;
use App\Models\User;
use App\Models\Cart;
use App\Models\CartItem;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CartTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test guests are unauthorized to view or modify cart.
     */
    public function test_guest_is_unauthorized_to_access_cart(): void
    {
        $this->getJson('/api/v1/cart')->assertStatus(401);
        $this->postJson('/api/v1/cart/items', ['product_id' => 1])->assertStatus(401);
        $this->putJson('/api/v1/cart/items/1', ['quantity' => 2])->assertStatus(401);
        $this->deleteJson('/api/v1/cart/items/1')->assertStatus(401);
        $this->deleteJson('/api/v1/cart')->assertStatus(401);
    }

    /**
     * Test authenticated user can view empty cart.
     */
    public function test_authenticated_user_can_view_empty_cart(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $response = $this->getJson('/api/v1/cart', [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'restaurant_id' => null,
                    'restaurant_name' => null,
                    'items' => [],
                    'total_price' => 0.0,
                ],
            ]);
    }

    /**
     * Test adding items to the cart and locking to a restaurant.
     */
    public function test_user_can_add_item_to_cart_and_locks_to_restaurant(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);
        $product = Product::factory()->create([
            'restaurant_id' => $restaurant->id,
            'category_id' => $category->id,
            'price' => 15.00,
            'is_available' => true,
        ]);

        // Add 1 item
        $response = $this->postJson('/api/v1/cart/items', [
            'product_id' => $product->id,
            'quantity' => 2,
        ], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'restaurant_id' => $restaurant->id,
                    'total_price' => 30.0, // 15.00 * 2
                ]
            ])
            ->assertJsonCount(1, 'data.items');

        // Check database state
        $cart = Cart::where('user_id', $user->id)->first();
        $this->assertEquals($restaurant->id, $cart->restaurant_id);

        $this->assertDatabaseHas('cart_items', [
            'cart_id' => $cart->id,
            'product_id' => $product->id,
            'quantity' => 2,
        ]);
    }

    /**
     * Test incrementing quantity on adding duplicate item.
     */
    public function test_adding_duplicate_item_increments_quantity(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);
        $product = Product::factory()->create([
            'restaurant_id' => $restaurant->id,
            'category_id' => $category->id,
            'price' => 10.00,
        ]);

        // Add 1st time
        $this->postJson('/api/v1/cart/items', ['product_id' => $product->id, 'quantity' => 1], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        // Add 2nd time
        $response = $this->postJson('/api/v1/cart/items', ['product_id' => $product->id, 'quantity' => 3], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.total_price', 40) // 10.00 * (1 + 3)
            ->assertJsonPath('data.items.0.quantity', 4);
    }

    /**
     * Test adding products from different restaurants fails.
     */
    public function test_user_cannot_add_items_from_different_restaurants(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $restaurant1 = Restaurant::factory()->create();
        $restaurant2 = Restaurant::factory()->create();

        $category1 = Category::factory()->create(['restaurant_id' => $restaurant1->id]);
        $category2 = Category::factory()->create(['restaurant_id' => $restaurant2->id]);

        $product1 = Product::factory()->create(['restaurant_id' => $restaurant1->id, 'category_id' => $category1->id]);
        $product2 = Product::factory()->create(['restaurant_id' => $restaurant2->id, 'category_id' => $category2->id]);

        // Add item from restaurant 1 (locks cart to restaurant 1)
        $this->postJson('/api/v1/cart/items', ['product_id' => $product1->id], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        // Attempt adding item from restaurant 2 (should fail)
        $response = $this->postJson('/api/v1/cart/items', ['product_id' => $product2->id], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['product_id']);
    }

    /**
     * Test updating cart item quantity.
     */
    public function test_user_can_update_cart_item_quantity(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);
        $product = Product::factory()->create([
            'restaurant_id' => $restaurant->id,
            'category_id' => $category->id,
            'price' => 10.00,
        ]);

        // Add item
        $addRes = $this->postJson('/api/v1/cart/items', ['product_id' => $product->id, 'quantity' => 1], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $cartItemId = $addRes->json('data.items.0.id');

        // Update quantity to 5
        $response = $this->putJson("/api/v1/cart/items/{$cartItemId}", [
            'quantity' => 5,
        ], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.total_price', 50)
            ->assertJsonPath('data.items.0.quantity', 5);
    }

    /**
     * Test removing a single cart item.
     */
    public function test_user_can_remove_item_and_empty_cart_unlocks_restaurant(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);
        $product = Product::factory()->create(['restaurant_id' => $restaurant->id, 'category_id' => $category->id]);

        // Add item
        $addRes = $this->postJson('/api/v1/cart/items', ['product_id' => $product->id], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $cartItemId = $addRes->json('data.items.0.id');

        // Delete item
        $response = $this->deleteJson("/api/v1/cart/items/{$cartItemId}", [], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.restaurant_id', null)
            ->assertJsonCount(0, 'data.items');

        $this->assertDatabaseMissing('cart_items', ['id' => $cartItemId]);
    }

    /**
     * Test clearing the cart.
     */
    public function test_user_can_clear_cart(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);
        $product1 = Product::factory()->create(['restaurant_id' => $restaurant->id, 'category_id' => $category->id]);
        $product2 = Product::factory()->create(['restaurant_id' => $restaurant->id, 'category_id' => $category->id]);

        $this->postJson('/api/v1/cart/items', ['product_id' => $product1->id], [
            'Authorization' => 'Bearer ' . $token,
        ]);
        $this->postJson('/api/v1/cart/items', ['product_id' => $product2->id], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        // Clear cart
        $response = $this->deleteJson('/api/v1/cart', [], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.restaurant_id', null)
            ->assertJsonCount(0, 'data.items');

        $cart = Cart::where('user_id', $user->id)->first();
        $this->assertEquals(0, $cart->items()->count());
    }
}
