<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class CartItemRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Authenticated user can modify their cart
        return $this->user() !== null;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $isPost = $this->isMethod('post');

        return [
            'product_id' => [$isPost ? 'required' : 'sometimes', 'exists:products,id'],
            'quantity' => [$isPost ? 'sometimes' : 'required', 'integer', 'min:1'],
        ];
    }
}
