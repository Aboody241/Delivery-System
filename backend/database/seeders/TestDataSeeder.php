<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Restaurant;
use App\Models\Category;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class TestDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Seed Admin User
        $admin = User::updateOrCreate(
            ['email' => 'admin@admin.com'],
            [
                'name' => 'Admin User',
                'email' => 'admin@admin.com',
                'password' => Hash::make('password'),
                'role' => 'admin',
            ]
        );

        // 2. Seed Customer User
        $customer = User::updateOrCreate(
            ['email' => 'customer@example.com'],
            [
                'name' => 'John Doe',
                'email' => 'customer@example.com',
                'password' => Hash::make('password'),
                'role' => 'customer',
                'phone' => '+1 (555) 012-3456',
                'address' => '456 Elm Street, Suite 4, Brooklyn, NY',
            ]
        );

        // 3. Seed Restaurants, Categories & Products
        // Restaurant A
        $kfc = Restaurant::updateOrCreate(
            ['name' => 'KFC'],
            [
                'description' => 'Fried chicken buckets, burger meals and delicious crispy wings.',
                'address' => '100 Broadway St, New York, NY',
                'phone' => '+1 (555) 001-1000',
                'is_active' => true,
            ]
        );

        $kfcBurgers = Category::create([
            'restaurant_id' => $kfc->id,
            'name' => 'Chicken Burgers',
            'description' => 'Delicious signature crispy chicken burgers.',
        ]);

        $kfcBuckets = Category::create([
            'restaurant_id' => $kfc->id,
            'name' => 'Bucket Meals',
            'description' => 'Perfect chicken buckets for sharing.',
        ]);

        $burger1 = Product::create([
            'restaurant_id' => $kfc->id,
            'category_id' => $kfcBurgers->id,
            'name' => 'Zinger Burger',
            'description' => 'Crispy chicken breast with fresh lettuce and mayo in a warm bun.',
            'price' => 7.99,
            'is_available' => true,
        ]);

        $burger2 = Product::create([
            'restaurant_id' => $kfc->id,
            'category_id' => $kfcBurgers->id,
            'name' => 'Tower Burger',
            'description' => 'Original recipe chicken fillet with hashbrown and cheese.',
            'price' => 9.49,
            'is_available' => true,
        ]);

        $bucket1 = Product::create([
            'restaurant_id' => $kfc->id,
            'category_id' => $kfcBuckets->id,
            'name' => '9pc Chicken Bucket',
            'description' => 'Nine pieces of original recipe chicken.',
            'price' => 18.99,
            'is_available' => true,
        ]);

        // Restaurant B
        $pizza = Restaurant::updateOrCreate(
            ['name' => 'Bella Italia'],
            [
                'description' => 'Traditional Neapolitan style woodfired pizzas and pastas.',
                'address' => '250 Fifth Ave, New York, NY',
                'phone' => '+1 (555) 002-2000',
                'is_active' => true,
            ]
        );

        $pizzaCat = Category::create([
            'restaurant_id' => $pizza->id,
            'name' => 'Woodfired Pizzas',
            'description' => 'Hand-stretched sourdough pizzas.',
        ]);

        $pizza1 = Product::create([
            'restaurant_id' => $pizza->id,
            'category_id' => $pizzaCat->id,
            'name' => 'Pizza Margherita',
            'description' => 'Tomato sauce, fresh mozzarella cheese and organic basil.',
            'price' => 12.99,
            'is_available' => true,
        ]);

        $pizza2 = Product::create([
            'restaurant_id' => $pizza->id,
            'category_id' => $pizzaCat->id,
            'name' => 'Pizza Pepperoni',
            'description' => 'Italian pepperoni, mozzarella and spiced red sauce.',
            'price' => 14.99,
            'is_available' => true,
        ]);

        // 4. Seed Orders
        // Order 1: Pending from KFC
        $order1 = Order::create([
            'user_id' => $customer->id,
            'restaurant_id' => $kfc->id,
            'status' => 'pending',
            'total_amount' => 24.97,
            'delivery_address' => $customer->address,
            'notes' => 'Please bring extra ketchup sachets.',
        ]);

        OrderItem::create([
            'order_id' => $order1->id,
            'product_id' => $burger1->id,
            'product_name' => $burger1->name,
            'price' => $burger1->price,
            'quantity' => 2,
        ]);

        OrderItem::create([
            'order_id' => $order1->id,
            'product_id' => $burger2->id,
            'product_name' => $burger2->name,
            'price' => $burger2->price,
            'quantity' => 1,
        ]);

        // Order 2: preparing from Bella Italia
        $order2 = Order::create([
            'user_id' => $customer->id,
            'restaurant_id' => $pizza->id,
            'status' => 'preparing',
            'total_amount' => 40.97,
            'delivery_address' => '789 Queen Ave, Apt 2B, Brooklyn, NY',
            'notes' => 'Ring bell on arrival.',
        ]);

        OrderItem::create([
            'order_id' => $order2->id,
            'product_id' => $pizza1->id,
            'product_name' => $pizza1->name,
            'price' => $pizza1->price,
            'quantity' => 2,
        ]);

        OrderItem::create([
            'order_id' => $order2->id,
            'product_id' => $pizza2->id,
            'product_name' => $pizza2->name,
            'price' => $pizza2->price,
            'quantity' => 1,
        ]);

        // Order 3: delivered from KFC
        $order3 = Order::create([
            'user_id' => $customer->id,
            'restaurant_id' => $kfc->id,
            'status' => 'delivered',
            'total_amount' => 18.99,
            'delivery_address' => $customer->address,
            'notes' => null,
        ]);

        OrderItem::create([
            'order_id' => $order3->id,
            'product_id' => $bucket1->id,
            'product_name' => $bucket1->name,
            'price' => $bucket1->price,
            'quantity' => 1,
        ]);

        $this->command->info('✅ Test environment seeded successfully!');
    }
}
