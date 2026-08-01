<?php

namespace App\Services;

use App\Models\Product;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Storage;

class ProductService
{
    /**
     * Get products for a specific restaurant with filters and pagination.
     *
     * @param  int  $restaurantId
     * @param  array  $filters
     * @return \Illuminate\Contracts\Pagination\LengthAwarePaginator
     */
    public function getByRestaurant(int $restaurantId, array $filters): LengthAwarePaginator
    {
        $query = Product::where('restaurant_id', $restaurantId);

        // Filter by category
        if (!empty($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        // Search by name/description
        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        // Apply only available constraint for guests
        if (isset($filters['only_available']) && $filters['only_available'] === true) {
            $query->where('is_available', true);
        }

        $perPage = $filters['per_page'] ?? 15;

        return $query->latest()->paginate($perPage);
    }

    /**
     * Get a single product by ID.
     *
     * @param  int  $id
     * @return \App\Models\Product|null
     */
    public function getById(int $id): ?Product
    {
        return Product::find($id);
    }

    /**
     * Create a new product.
     *
     * @param  int  $restaurantId
     * @param  array  $data
     * @return \App\Models\Product
     */
    public function create(int $restaurantId, array $data): Product
    {
        if (!empty($data['image']) && $data['image'] instanceof \Illuminate\Http\UploadedFile) {
            $path = $data['image']->store('products', 'public');
            $data['image_url'] = asset('storage/' . $path);
        }

        return Product::create([
            'restaurant_id' => $restaurantId,
            'category_id' => $data['category_id'],
            'name' => $data['name'],
            'description' => $data['description'] ?? null,
            'price' => $data['price'],
            'image_url' => $data['image_url'] ?? null,
            'is_available' => $data['is_available'] ?? true,
        ]);
    }

    /**
     * Update an existing product.
     *
     * @param  \App\Models\Product  $product
     * @param  array  $data
     * @return \App\Models\Product
     */
    public function update(Product $product, array $data): Product
    {
        if (!empty($data['image']) && $data['image'] instanceof \Illuminate\Http\UploadedFile) {
            // Delete old file if existed locally
            if (!empty($product->image_url)) {
                $oldPath = str_replace(asset('storage/'), '', $product->image_url);
                Storage::disk('public')->delete($oldPath);
            }

            $path = $data['image']->store('products', 'public');
            $data['image_url'] = asset('storage/' . $path);
        }

        $product->update(array_filter([
            'category_id' => $data['category_id'] ?? null,
            'name' => $data['name'] ?? null,
            'description' => $data['description'] ?? null,
            'price' => $data['price'] ?? null,
            'image_url' => $data['image_url'] ?? null,
            'is_available' => isset($data['is_available']) ? (bool) $data['is_available'] : null,
        ], function ($value) {
            return !is_null($value);
        }));

        return $product->fresh();
    }

    /**
     * Delete a product and its associated image.
     *
     * @param  \App\Models\Product  $product
     * @return bool|null
     */
    public function delete(Product $product): ?bool
    {
        if (!empty($product->image_url)) {
            $oldPath = str_replace(asset('storage/'), '', $product->image_url);
            Storage::disk('public')->delete($oldPath);
        }

        return $product->delete();
    }
}
