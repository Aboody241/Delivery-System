<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CartItemResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $product = $this->product;
        $price = $product ? (float) $product->price : 0.0;
        $quantity = (int) $this->quantity;

        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'product_name' => $product?->name,
            'product_image_url' => $product?->image_url,
            'price' => $price,
            'quantity' => $quantity,
            'subtotal' => round($price * $quantity, 2),
        ];
    }
}
