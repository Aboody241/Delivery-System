<?php

namespace App\Http\Requests\Api\V1;

use App\Models\Order;
use Illuminate\Foundation\Http\FormRequest;

class OrderRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        $user = $this->user();
        if (!$user) {
            return false;
        }

        // If it's a status update request
        if ($this->route('id')) {
            $orderId = $this->route('id');
            $order = Order::find($orderId);

            if (!$order) {
                return true; // Let controller handle 404
            }

            // Admins/owners can update to any status
            if (in_array($user->role, ['admin', 'owner'])) {
                return true;
            }

            // Customer can only cancel their own order and only if it's pending
            if ($user->role === 'customer' && $order->user_id === $user->id) {
                $requestedStatus = $this->input('status');
                if ($requestedStatus === 'cancelled' && $order->status === 'pending') {
                    return true;
                }
            }

            return false;
        }

        // Store request is open to any authenticated user
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        // If it's a status update request
        if ($this->route('id')) {
            return [
                'status' => ['required', 'string', 'in:pending,accepted,preparing,ready,out_for_delivery,delivered,cancelled'],
            ];
        }

        return [
            'delivery_address' => ['nullable', 'string', 'max:1000'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
