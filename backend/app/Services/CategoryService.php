<?php

namespace App\Services;

use App\Models\Category;
use Illuminate\Database\Eloquent\Collection;

class CategoryService
{
    /**
     * Get categories for a specific restaurant.
     *
     * @param  int  $restaurantId
     * @return \Illuminate\Database\Eloquent\Collection<int, \App\Models\Category>
     */
    public function getByRestaurant(int $restaurantId): Collection
    {
        return Category::where('restaurant_id', $restaurantId)->get();
    }

    /**
     * Get a single category by ID.
     *
     * @param  int  $id
     * @return \App\Models\Category|null
     */
    public function getById(int $id): ?Category
    {
        return Category::find($id);
    }

    /**
     * Create a category under a specific restaurant.
     *
     * @param  int  $restaurantId
     * @param  array  $data
     * @return \App\Models\Category
     */
    public function create(int $restaurantId, array $data): Category
    {
        return Category::create([
            'restaurant_id' => $restaurantId,
            'name' => $data['name'],
            'description' => $data['description'] ?? null,
        ]);
    }

    /**
     * Update an existing category.
     *
     * @param  \App\Models\Category  $category
     * @param  array  $data
     * @return \App\Models\Category
     */
    public function update(Category $category, array $data): Category
    {
        $category->update(array_filter([
            'name' => $data['name'] ?? null,
            'description' => $data['description'] ?? null,
        ], function ($value) {
            return !is_null($value);
        }));

        return $category->fresh();
    }

    /**
     * Delete a category.
     *
     * @param  \App\Models\Category  $category
     * @return bool|null
     */
    public function delete(Category $category): ?bool
    {
        return $category->delete();
    }
}
