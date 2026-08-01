<?php

namespace Database\Factories;

use App\Models\Order;
use App\Models\Restaurant;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Order>
 */
class OrderFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = Order::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'restaurant_id' => Restaurant::factory(),
            'status' => 'pending',
            'total_amount' => $this->faker->randomFloat(2, 10, 200),
            'delivery_address' => $this->faker->address(),
            'notes' => $this->faker->sentence(),
        ];
    }
}
