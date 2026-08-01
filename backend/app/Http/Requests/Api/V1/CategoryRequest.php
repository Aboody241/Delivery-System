<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CategoryRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Admin or owner role can perform CRUD actions on categories
        return $this->user() && in_array($this->user()->role, ['admin', 'owner']);
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $isPost = $this->isMethod('post');

        if ($isPost) {
            $restaurantId = $this->route('restaurant');
            $uniqueRule = Rule::unique('categories', 'name')->where('restaurant_id', $restaurantId);
        } else {
            $categoryId = $this->route('id');
            $category = \App\Models\Category::find($categoryId);
            $restaurantId = $category?->restaurant_id;
            $uniqueRule = Rule::unique('categories', 'name')->where('restaurant_id', $restaurantId)->ignore($categoryId);
        }

        return [
            'name' => [$isPost ? 'required' : 'sometimes', 'string', 'max:255', $uniqueRule],
            'description' => ['nullable', 'string'],
        ];
    }
}
