<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class UserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Only admins or owners can perform user management
        $user = $this->user();
        return $user && in_array($user->role, ['admin', 'owner']);
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $isPost = $this->isMethod('post');
        $userId = $this->route('user'); // Get target user ID from route parameter '/users/{user}'

        return [
            'name' => [$isPost ? 'required' : 'sometimes', 'string', 'max:255'],
            'email' => [
                $isPost ? 'required' : 'sometimes',
                'string',
                'email',
                'max:255',
                'unique:users,email' . ($userId ? ',' . $userId : ''),
            ],
            'password' => [$isPost ? 'required' : 'nullable', 'string', 'min:6'],
            'role' => [$isPost ? 'required' : 'sometimes', 'string', 'in:admin,owner,customer,driver'],
            'phone' => ['nullable', 'string', 'max:50'],
            'address' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
