<?php

namespace App\Services;

use App\Models\Restaurant;
use Illuminate\Database\Eloquent\Collection;

class RestaurantService
{
    /**
     * Get a list of restaurants.
     *
     * @param  bool  $onlyActive
     * @return \Illuminate\Database\Eloquent\Collection<int, \App\Models\Restaurant>
     */
    public function getAll(bool $onlyActive = true): Collection
    {
        $query = Restaurant::query();

        if ($onlyActive) {
            $query->where('is_active', true);
        }

        return $query->latest()->get();
    }

    /**
     * Get a single restaurant by ID.
     *
     * @param  int  $id
     * @return \App\Models\Restaurant|null
     */
    public function getById(int $id): ?Restaurant
    {
        return Restaurant::find($id);
    }

    /**
     * Create a new restaurant.
     *
     * @param  array  $data
     * @return \App\Models\Restaurant
     */
    public function create(array $data): Restaurant
    {
        return Restaurant::create([
            'name' => $data['name'],
            'description' => $data['description'] ?? null,
            'address' => $data['address'],
            'phone' => $data['phone'],
            'image_url' => $data['image_url'] ?? null,
            'is_active' => $data['is_active'] ?? true,
        ]);
    }

    /**
     * Update an existing restaurant.
     *
     * @param  \App\Models\Restaurant  $restaurant
     * @param  array  $data
     * @return \App\Models\Restaurant
     */
    public function update(Restaurant $restaurant, array $data): Restaurant
    {
        $restaurant->update(array_filter([
            'name' => $data['name'] ?? null,
            'description' => $data['description'] ?? null,
            'address' => $data['address'] ?? null,
            'phone' => $data['phone'] ?? null,
            'image_url' => $data['image_url'] ?? null,
            'is_active' => isset($data['is_active']) ? (bool) $data['is_active'] : null,
        ], function ($value) {
            return !is_null($value);
        }));

        return $restaurant->fresh();
    }

    /**
     * Delete a restaurant.
     *
     * @param  \App\Models\Restaurant  $restaurant
     * @return bool|null
     */
    public function delete(Restaurant $restaurant): ?bool
    {
        return $restaurant->delete();
    }
}
