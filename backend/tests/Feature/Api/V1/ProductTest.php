<?php

namespace Tests\Feature\Api\V1;

use App\Models\Category;
use App\Models\Product;
use App\Models\Restaurant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test listing products of a restaurant with pagination, category filter, and search.
     */
    public function test_public_user_can_list_restaurant_products_with_filters(): void
    {
        $restaurant = Restaurant::factory()->create();
        $category1 = Category::factory()->create(['restaurant_id' => $restaurant->id]);
        $category2 = Category::factory()->create(['restaurant_id' => $restaurant->id]);

        Product::factory()->create([
            'restaurant_id' => $restaurant->id,
            'category_id' => $category1->id,
            'name' => 'Spaghetti Carbonara',
            'description' => 'Creamy bacon pasta',
            'is_available' => true,
        ]);

        Product::factory()->create([
            'restaurant_id' => $restaurant->id,
            'category_id' => $category2->id,
            'name' => 'Cheeseburger',
            'description' => 'Flame grilled beef burger',
            'is_available' => true,
        ]);

        Product::factory()->create([
            'restaurant_id' => $restaurant->id,
            'category_id' => $category1->id,
            'name' => 'Hidden Pasta',
            'is_available' => false, // unavailable product
        ]);

        // 1. Check guest sees only available products
        $response = $this->getJson("/api/v1/restaurants/{$restaurant->id}/products");
        $response->assertStatus(200)
            ->assertJsonCount(2, 'data')
            ->assertJsonStructure([
                'status',
                'data',
                'meta' => ['current_page', 'last_page', 'per_page', 'total'],
                'links' => ['first', 'last', 'prev', 'next']
            ]);

        // 2. Filter by category
        $responseCategory = $this->getJson("/api/v1/restaurants/{$restaurant->id}/products?category_id={$category2->id}");
        $responseCategory->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Cheeseburger');

        // 3. Search by name/description
        $responseSearch = $this->getJson("/api/v1/restaurants/{$restaurant->id}/products?search=pasta");
        $responseSearch->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Spaghetti Carbonara');
    }

    /**
     * Test admin can view all products including unavailable ones.
     */
    public function test_admin_can_view_unavailable_products(): void
    {
        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);

        Product::factory()->create([
            'restaurant_id' => $restaurant->id,
            'category_id' => $category->id,
            'name' => 'Hidden Pasta',
            'is_available' => false,
        ]);

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $response = $this->getJson("/api/v1/restaurants/{$restaurant->id}/products", [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data');
    }

    /**
     * Test retrieving a single product detail.
     */
    public function test_public_user_can_view_single_product(): void
    {
        $product = Product::factory()->create(['name' => 'Margherita Pizza']);

        $response = $this->getJson("/api/v1/products/{$product->id}");

        $response->assertStatus(200)
            ->assertJsonPath('data.name', 'Margherita Pizza');
    }

    /**
     * Test admin can create a product with an uploaded image.
     */
    public function test_admin_can_create_product_with_image_upload(): void
    {
        Storage::fake('public');

        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $image = UploadedFile::fake()->image('pizza.jpg');

        $payload = [
            'category_id' => $category->id,
            'name' => 'Pepperoni Supreme',
            'description' => 'Spicy pepperoni',
            'price' => 12.99,
            'image' => $image,
        ];

        $response = $this->postJson("/api/v1/restaurants/{$restaurant->id}/products", $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.name', 'Pepperoni Supreme');

        // Check if file was stored on disk
        $product = Product::latest()->first();
        $storedPath = str_replace(asset('storage/'), '', $product->image_url);
        Storage::disk('public')->assertExists($storedPath);
    }

    /**
     * Test customer cannot create a product.
     */
    public function test_customer_cannot_create_product(): void
    {
        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);

        $customer = User::factory()->create(['role' => 'customer']);
        $token = $customer->createToken('auth_token')->plainTextToken;

        $payload = [
            'category_id' => $category->id,
            'name' => 'Pepperoni Supreme',
            'price' => 12.99,
        ];

        $response = $this->postJson("/api/v1/restaurants/{$restaurant->id}/products", $payload, [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(403);
    }

    /**
     * Test admin can update a product and replace its image.
     */
    public function test_admin_can_update_product(): void
    {
        Storage::fake('public');

        $restaurant = Restaurant::factory()->create();
        $category = Category::factory()->create(['restaurant_id' => $restaurant->id]);

        $product = Product::factory()->create([
            'restaurant_id' => $restaurant->id,
            'category_id' => $category->id,
            'name' => 'Old Name',
            'image_url' => asset('storage/products/old.jpg'),
        ]);

        // Place old fake image on disk
        Storage::disk('public')->put('products/old.jpg', 'fake content');

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $newImage = UploadedFile::fake()->image('new.jpg');

        $payload = [
            'name' => 'Updated Product Name',
            'image' => $newImage,
        ];

        // PUT request with multipart image replacement in testing
        // Note: For multipart files in PUT, we can simulate by sending POST with _method=PUT
        $response = $this->postJson("/api/v1/products/{$product->id}", array_merge($payload, ['_method' => 'PUT']), [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.name', 'Updated Product Name');

        // Old file deleted
        Storage::disk('public')->assertMissing('products/old.jpg');

        // New file exists
        $updatedProduct = $product->fresh();
        $newPath = str_replace(asset('storage/'), '', $updatedProduct->image_url);
        Storage::disk('public')->assertExists($newPath);
    }

    /**
     * Test admin can delete a product.
     */
    public function test_admin_can_delete_product(): void
    {
        Storage::fake('public');

        $product = Product::factory()->create([
            'name' => 'To Delete',
            'image_url' => asset('storage/products/delete.jpg'),
        ]);
        Storage::disk('public')->put('products/delete.jpg', 'fake content');

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('auth_token')->plainTextToken;

        $response = $this->deleteJson("/api/v1/products/{$product->id}", [], [
            'Authorization' => 'Bearer ' . $token,
        ]);

        $response->assertStatus(200);

        // Product missing from database
        $this->assertDatabaseMissing('products', ['id' => $product->id]);

        // Image file deleted from storage disk
        Storage::disk('public')->assertMissing('products/delete.jpg');
    }
}
