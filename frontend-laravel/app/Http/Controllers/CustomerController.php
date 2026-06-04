<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CustomerController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Dashboard pelanggan — pesanan aktif, riwayat, tracking.
     */
    public function dashboard(Request $request)
    {
        $token = session('auth_token');
        $result = $this->api->getOrders($token);
        $orders = $result['success'] ? $result['data'] : [];

        return Inertia::render('Customer/Dashboard', [
            'orders' => $orders,
            'username' => session('auth_username', 'Customer'),
            'user' => session('auth_user', []),
        ]);
    }

    /**
     * Upload bukti pembayaran.
     */
    public function uploadProof(Request $request, string $orderId)
    {
        $token = session('auth_token');

        $request->validate([
            'proof' => 'required|file|image|max:4096',
        ]);

        $proofUrl = null;
        if ($request->hasFile('proof')) {
            $proofPath = $request->file('proof')->store('proofs', 'public');
            $proofUrl = asset('storage/' . $proofPath);
        }

        $result = $this->api->uploadProof($token, $orderId, $proofUrl);

        if (!$result['success']) {
            return back()->with('error', 'Gagal mengunggah bukti pembayaran.');
        }

        return back()->with('success', 'Bukti pembayaran berhasil diunggah.');
    }

    /**
     * Lacak pesanan berdasarkan ID.
     */
    public function trackOrder(Request $request)
    {
        $token = session('auth_token');
        $orderId = $request->input('orderId');
        $order = null;
        $steps = [];
        $currentStep = -1;

        if ($orderId) {
            $result = $this->api->getOrderById($token, $orderId);
            if ($result['success']) {
                $order = $result['data'];

                // Check if this order uses Biteship Tracking
                $trackingResult = $this->api->getTracking($token, $orderId);

                if ($trackingResult['success'] && isset($trackingResult['data']['courier']['history'])) {
                    // It's a Biteship tracked order, map the history to steps
                    $history = $trackingResult['data']['courier']['history'];
                    $steps = [];
                    foreach ($history as $h) {
                        $dateStr = $h['updated_at'] ?? '';
                        try {
                            $dateObj = new \DateTime($dateStr);
                            $dateObj->setTimezone(new \DateTimeZone('Asia/Jakarta'));
                            $formattedTime = $dateObj->format('d M Y, H:i');
                        } catch (\Exception $e) {
                            $formattedTime = $dateStr;
                        }

                        $steps[] = [
                            'title' => $h['note'] ?? $h['status'],
                            'time'  => $formattedTime,
                            'status'=> $h['status']
                        ];
                    }
                    $currentStep = count($steps) - 1; // Always the last step in history is the current step
                } else {
                    // Fallback to static timeline for non-Biteship orders (e.g. Ambil Di Toko, Kurir Toko)
                    $steps = [
                        ['title' => 'Pesanan Dibuat', 'time' => $order['createdAt'] ?? ''],
                        ['title' => 'Pembayaran Terverifikasi', 'time' => ''],
                        ['title' => 'Dalam Pengiriman', 'time' => ''],
                        ['title' => 'Pesanan Selesai', 'time' => ''],
                    ];

                    // Determine current step based on order status
                    $status = strtolower($order['status'] ?? '');
                    $currentStep = match ($status) {
                        'pending' => 0,
                        'success' => 1,
                        'verified' => 1,
                        'shipping' => 2,
                        'completed' => 3,
                        default => 0,
                    };
                }
            }
        }

        return Inertia::render('Customer/Tracking', [
            'order' => $order,
            'queryId' => $orderId ?? '',
            'steps' => $steps,
            'currentStep' => $currentStep,
        ]);
    }
    public function completeOrder(Request $request, string $orderId)
    {
        $token = session('auth_token');
        $result = $this->api->completeOrder($token, $orderId);

        if (!$result['success']) {
            return back()->with('error', 'Gagal menyelesaikan pesanan.');
        }

        return back()->with('success', 'Pesanan berhasil diselesaikan. Terima kasih!');
    }
}
