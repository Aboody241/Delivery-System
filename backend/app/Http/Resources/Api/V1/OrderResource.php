<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
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

        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'restaurant_id' => $this->restaurant_id,
            'restaurant_name' => $restaurant?->name,
            'status' => $this->status,
            'total_amount' => (float) $this->total_amount,
            'delivery_address' => $this->delivery_address,
            'notes' => $this->notes,
            'items' => OrderItemResource::collection($items),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
