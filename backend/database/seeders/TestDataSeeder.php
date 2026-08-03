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
use Illuminate\Support\Facades\Schema;

class TestDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Prevent integrity constraint errors by safely clearing tables
        Schema::disableForeignKeyConstraints();
        OrderItem::truncate();
        Order::truncate();
        Product::truncate();
        Category::truncate();
        Restaurant::truncate();
        Schema::enableForeignKeyConstraints();

        // 1. Seed Admin User
        $admin = User::updateOrCreate(
            ['email' => 'admin@admin.com'],
            [
                'name' => 'Admin User',
                'email' => 'admin@admin.com',
                'password' => Hash::make('password'),
                'role' => 'admin',
                'image_url' => 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
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
                'image_url' => 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
            ]
        );

        // 3. Seed Restaurants, Categories & Products

        // KFC
        $kfc = Restaurant::create([
            'name' => 'KFC',
            'description' => 'Fried chicken buckets, burger meals, and delicious crispy wings.',
            'address' => '100 Broadway St, New York, NY',
            'phone' => '+1 (555) 001-1000',
            'image_url' => 'https://images.unsplash.com/photo-1513639776629-7b61b0ac5987?w=500',
            'is_active' => true,
        ]);

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
            'image_url' => 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
            'is_available' => true,
        ]);

        $burger2 = Product::create([
            'restaurant_id' => $kfc->id,
            'category_id' => $kfcBurgers->id,
            'name' => 'Tower Burger',
            'description' => 'Original recipe chicken fillet with hashbrown and cheese.',
            'price' => 9.49,
            'image_url' => 'https://images.unsplash.com/photo-1525059696034-4967a8e1dca2?w=500',
            'is_available' => true,
        ]);

        $bucket1 = Product::create([
            'restaurant_id' => $kfc->id,
            'category_id' => $kfcBuckets->id,
            'name' => '9pc Chicken Bucket',
            'description' => 'Nine pieces of original recipe chicken.',
            'price' => 18.99,
            'image_url' => 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500',
            'is_available' => true,
        ]);

        // Bella Italia
        $pizza = Restaurant::create([
            'name' => 'Bella Italia',
            'description' => 'Traditional Neapolitan style woodfired pizzas and pastas.',
            'address' => '250 Fifth Ave, New York, NY',
            'phone' => '+1 (555) 002-2000',
            'image_url' => 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
            'is_active' => true,
        ]);

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
            'image_url' => 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500',
            'is_available' => true,
        ]);

        $pizza2 = Product::create([
            'restaurant_id' => $pizza->id,
            'category_id' => $pizzaCat->id,
            'name' => 'Pizza Pepperoni',
            'description' => 'Italian pepperoni, mozzarella and spiced red sauce.',
            'price' => 14.99,
            'image_url' => 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500',
            'is_available' => true,
        ]);

        // Burger Joint
        $burgerJoint = Restaurant::create([
            'name' => 'Burger Joint',
            'description' => 'Gourmet craft burgers made from 100% prime organic beef.',
            'address' => '50 Wall St, New York, NY',
            'phone' => '+1 (555) 003-3000',
            'image_url' => 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500',
            'is_active' => true,
        ]);

        $gourmetBurgers = Category::create([
            'restaurant_id' => $burgerJoint->id,
            'name' => 'Gourmet Burgers',
            'description' => 'Hearty, craft burgers with premium toppings.',
        ]);

        $sidesSnacks = Category::create([
            'restaurant_id' => $burgerJoint->id,
            'name' => 'Sides & Snacks',
            'description' => 'Perfect accompaniments for your burger.',
        ]);

        Product::create([
            'restaurant_id' => $burgerJoint->id,
            'category_id' => $gourmetBurgers->id,
            'name' => 'Double Bacon Cheeseburger',
            'description' => 'Two beef patties, crispy maple bacon, double cheddar, and home sauce.',
            'price' => 11.99,
            'image_url' => 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500',
            'is_available' => true,
        ]);

        Product::create([
            'restaurant_id' => $burgerJoint->id,
            'category_id' => $gourmetBurgers->id,
            'name' => 'Avocado Turkey Burger',
            'description' => 'Lean turkey patty, fresh avocado mash, swiss cheese, and wild greens.',
            'price' => 10.49,
            'image_url' => 'https://images.unsplash.com/photo-1525059696034-4967a8e1dca2?w=500',
            'is_available' => true,
        ]);

        Product::create([
            'restaurant_id' => $burgerJoint->id,
            'category_id' => $sidesSnacks->id,
            'name' => 'Crispy French Fries',
            'description' => 'Golden potato fries seasoned with sea salt and rosemary.',
            'price' => 3.49,
            'image_url' => 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500',
            'is_available' => true,
        ]);

        Product::create([
            'restaurant_id' => $burgerJoint->id,
            'category_id' => $sidesSnacks->id,
            'name' => 'Classic Onion Rings',
            'description' => 'Crispy beer-battered onion rings with smokey BBQ sauce.',
            'price' => 4.29,
            'image_url' => 'https://images.unsplash.com/photo-1639024471283-2bc7b3c6a267?w=500',
            'is_available' => true,
        ]);

        // Sushi Roll
        $sushi = Restaurant::create([
            'name' => 'Sushi Roll',
            'description' => 'Fresh handmade sushi, sashimi platters, and authentic tempura.',
            'address' => '300 Madison Ave, New York, NY',
            'phone' => '+1 (555) 004-4000',
            'image_url' => 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500',
            'is_active' => true,
        ]);

        $signatureRolls = Category::create([
            'restaurant_id' => $sushi->id,
            'name' => 'Signature Rolls',
            'description' => 'Famous sushi rolls crafted by our master chefs.',
        ]);

        $nigiriSashimi = Category::create([
            'restaurant_id' => $sushi->id,
            'name' => 'Nigiri & Sashimi',
            'description' => 'Slices of pristine raw fish over seasoned rice.',
        ]);

        Product::create([
            'restaurant_id' => $sushi->id,
            'category_id' => $signatureRolls->id,
            'name' => 'California Roll',
            'description' => 'Crab stick, avocado, cucumber, rolled with sesame seeds.',
            'price' => 10.99,
            'image_url' => 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=500',
            'is_available' => true,
        ]);

        Product::create([
            'restaurant_id' => $sushi->id,
            'category_id' => $signatureRolls->id,
            'name' => 'Spicy Tuna Roll',
            'description' => 'Chopped spicy yellowfin tuna, cucumber, topped with spicy mayo.',
            'price' => 11.99,
            'image_url' => 'https://images.unsplash.com/photo-1553621042-f6e147245754?w=500',
            'is_available' => true,
        ]);

        Product::create([
            'restaurant_id' => $sushi->id,
            'category_id' => $nigiriSashimi->id,
            'name' => 'Salmon Nigiri (4pcs)',
            'description' => 'Four pieces of delicate Atlantic salmon over pressed sushi rice.',
            'price' => 12.49,
            'image_url' => 'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=500',
            'is_available' => true,
        ]);

        // Sweet Oasis
        $sweetOasis = Restaurant::create([
            'name' => 'Sweet Oasis',
            'description' => 'A sweet escape of premium desserts, gourmet pastries, and hot beverages.',
            'address' => '72 Park Ave, New York, NY',
            'phone' => '+1 (555) 005-5000',
            'image_url' => 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500',
            'is_active' => true,
        ]);

        $decadentDesserts = Category::create([
            'restaurant_id' => $sweetOasis->id,
            'name' => 'Decadent Desserts',
            'description' => 'Luxurious sweet treats and cakes.',
        ]);

        $coffeeDrinks = Category::create([
            'restaurant_id' => $sweetOasis->id,
            'name' => 'Coffee & Hot Drinks',
            'description' => 'Premium hot coffee brews and warm teas.',
        ]);

        Product::create([
            'restaurant_id' => $sweetOasis->id,
            'category_id' => $decadentDesserts->id,
            'name' => 'Chocolate Lava Cake',
            'description' => 'Warm chocolate cake with a rich molten center, served with vanilla cream.',
            'price' => 5.99,
            'image_url' => 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500',
            'is_available' => true,
        ]);

        Product::create([
            'restaurant_id' => $sweetOasis->id,
            'category_id' => $decadentDesserts->id,
            'name' => 'New York Cheesecake',
            'description' => 'Creamy cheesecake base on a graham cracker crust with strawberry puree.',
            'price' => 6.49,
            'image_url' => 'https://images.unsplash.com/photo-1524351199679-46cddf530c04?w=500',
            'is_available' => true,
        ]);

        Product::create([
            'restaurant_id' => $sweetOasis->id,
            'category_id' => $coffeeDrinks->id,
            'name' => 'Vanilla Latte',
            'description' => 'Rich espresso blended with steamed milk and sweet Madagascar vanilla syrup.',
            'price' => 4.29,
            'image_url' => 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500',
            'is_available' => true,
        ]);

        // 4. Seed Orders (only keeping sample active/previous ones for customers)
        // Order 1: Pending from KFC
        $order1 = Order::create([
            'user_id' => $customer->id,
            'restaurant_id' => $kfc->id,
            'status' => 'pending',
            'total_amount' => 25.47,
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

        // Order 2: Preparing from Bella Italia
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

        // Order 3: Delivered from KFC
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

        $this->command->info('✅ Test environment seeded successfully with new restaurants & products!');
    }
}
