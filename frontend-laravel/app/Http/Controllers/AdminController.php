<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;
use Inertia\Inertia;

class AdminController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Dashboard admin — manajemen pembelian & customer.
     */
    public function dashboard(Request $request)
    {
        $token = session('auth_token');

        // Fetch orders
        $orderResult = $this->api->getOrders($token);
        $orders = $orderResult['success'] ? $orderResult['data'] : [];

        // Fetch customers
        $customerResult = $this->api->getCustomers($token);
        $customers = $customerResult['success'] ? $customerResult['data'] : [];

        // Calculate stats
        $pendingOrders = count(array_filter($orders, fn($o) => strtolower($o['status'] ?? '') === 'pending'));
        $verifiedOrders = count(array_filter($orders, fn($o) => strtolower($o['status'] ?? '') === 'verified'));

        return Inertia::render('Admin/Dashboard', [
            'orders' => $orders,
            'customers' => $customers,
            'username' => session('auth_username', 'Admin'),
            'stats' => [
                'totalOrders' => count($orders),
                'pendingOrders' => $pendingOrders,
                'verifiedOrders' => $verifiedOrders,
                'totalCustomers' => count($customers),
            ],
        ]);
    }

    /**
     * Update status pesanan (validasi pembayaran).
     */
    public function updateStatus(Request $request, string $orderId)
    {
        $token = session('auth_token');
        $result = $this->api->updateOrderStatus($token, $orderId, [
            'status' => $request->input('status'),
        ]);

        if (!$result['success']) {
            return back()->with('error', 'Gagal memperbarui status.');
        }

        return back()->with('success', 'Status pesanan berhasil diperbarui.');
    }

    /**
     * Toggle blokir/buka akses customer.
     */
    public function toggleBlock(string $username)
    {
        $token = session('auth_token');
        $result = $this->api->toggleBlock($token, $username);

        if (!$result['success']) {
            return back()->with('error', 'Gagal mengubah status akses.');
        }

        return back()->with('success', $result['data']['message'] ?? 'Status akses berhasil diubah.');
    }
}
