<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CartResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $restaurant = $this->restaurant;
        $items = $this->items ?? collect();

        // Calculate total price of the cart items
        $totalPrice = $items->sum(function ($item) {
            $price = $item->product ? (float) $item->product->price : 0.0;
            return $price * (int) $item->quantity;
        });

        return [
            'id' => $this->id,
            'restaurant_id' => $this->restaurant_id,
            'restaurant_name' => $restaurant?->name,
            'items' => CartItemResource::collection($items),
            'total_price' => round($totalPrice, 2),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
