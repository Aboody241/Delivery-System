<?php

namespace Tests\Feature\Api\V1;

use App\Models\Category;
use App\Models\Order;
use App\Models\Product;
use App\Models\Restaurant;
use App\Models\User;
use App\Services\CartService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrderTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test guests are unauthorized to access order endpoints.
     */
    public function test_guest_is_unauthorized_to_access_orders(): void
    {
        $this->getJson('/api/v1/orders')->assertStatus(401);
        $this->getJson('/api/v1/orders/1')->assertStatus(401);
        $this->postJson('/api/v1/orders')->assertStatus(401);
        $this->putJson('/api/v1/orders/1/status', ['status' => 'accepted'])->assertStatus(401);
    }

    /**
     * Test customer checkout converts active cart to order and empties cart.
     */
    public function test_customer_can_checkout_active_cart(): void
    {
        $user = User::factory()->create(['address' => 'Customer Address']);
        $token = $user->createToken('auth_token')->plainTextToken;

        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);
        $product = Product::factory()->create([
            'restaurant_id' => $restaurant->id,
            'category_id' => $category->id,
            'name' => 'Burger',
            'price' => 10.00,
        ]);

        // Add to cart first
        $cartService = app(CartService::class);
        $cart = $cartService->getOrCreateCart($user->id);
        $cartService->addItem($cart, $product->id, 2);

        // Checkout
        $response = $this->postJson('/api/v1/orders', [
            'delivery_address' => 'Specific Delivery Address',
            'notes' => 'Call on arrival',
        ], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'restaurant_id' => $restaurant->id,
                    'status' => 'pending',
                    'total_amount' => 20, // 10.00 * 2
                    'delivery_address' => 'Specific Delivery Address',
                    'notes' => 'Call on arrival',
                ]
            ]);

        // Assert cart is cleared
        $this->assertEquals(0, $cart->items()->count());
        $this->assertNull($cart->fresh()->restaurant_id);

        // Assert order items exist in DB
        $order = Order::latest()->first();
        $this->assertDatabaseHas('order_items', [
            'order_id' => $order->id,
            'product_id' => $product->id,
            'product_name' => 'Burger',
            'price' => 10.00,
            'quantity' => 2,
        ]);
    }

    /**
     * Test checkout fails on empty cart.
     */
    public function test_checkout_fails_on_empty_cart(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $response = $this->postJson('/api/v1/orders', [], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['cart']);
    }

    /**
     * Test customer only views their own order history.
     */
    public function test_customer_can_only_view_own_orders(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        $token1 = $user1->createToken('auth_token')->plainTextToken;

        // Order for user 1
        Order::factory()->create(['user_id' => $user1->id]);
        // Order for user 2
        Order::factory()->create(['user_id' => $user2->id]);

        $response = $this->getJson('/api/v1/orders', [
            'Authorization' => 'Bearer ' . $token1,
        ]);

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data');
    }

    /**
     * Test admin can view all orders history.
     */
    public function test_admin_can_view_all_orders(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        Order::factory()->create(['user_id' => $user1->id]);
        Order::factory()->create(['user_id' => $user2->id]);

        $response = $this->getJson('/api/v1/orders', [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    /**
     * Test customer cannot show other customer order details.
     */
    public function test_customer_cannot_view_other_user_order(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        $token1 = $user1->createToken('auth_token')->plainTextToken;

        $order2 = Order::factory()->create(['user_id' => $user2->id]);

        $response = $this->getJson("/api/v1/orders/{$order2->id}", [
            'Authorization' => 'Bearer ' . $token1,
        ]);

        $response->assertStatus(403);
    }

    /**
     * Test customer can cancel pending order.
     */
    public function test_customer_can_cancel_pending_order(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $order = Order::factory()->create([
            'user_id' => $user->id,
            'status' => 'pending',
        ]);

        $response = $this->putJson("/api/v1/orders/{$order->id}/status", [
            'status' => 'cancelled',
        ], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.status', 'cancelled');
    }

    /**
     * Test customer cannot cancel accepted order.
     */
    public function test_customer_cannot_cancel_accepted_order(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('auth_token')->plainTextToken;

        $order = Order::factory()->create([
            'user_id' => $user->id,
            'status' => 'accepted', // already accepted
        ]);

        $response = $this->putJson("/api/v1/orders/{$order->id}/status", [
            'status' => 'cancelled',
        ], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(403); // Forbidden
    }

    /**
     * Test admin can update order to any status.
     */
    public function test_admin_can_update_status_to_anything(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $order = Order::factory()->create(['status' => 'pending']);

        $response = $this->putJson("/api/v1/orders/{$order->id}/status", [
            'status' => 'preparing',
        ], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.status', 'preparing');
    }
}
